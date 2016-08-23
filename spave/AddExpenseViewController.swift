//
//  AddExpenseViewController.swift
//  spave
//
//  Created by Dominik Faber on 12.08.16.
//  Copyright © 2016 granolahouse. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreLocation

class AddExpenseViewController: UIViewController, UIGestureRecognizerDelegate, CLLocationManagerDelegate {

    
    var locationManager: CLLocationManager = CLLocationManager()
    
    //We want to track in GBP
    let currencyToTrack = Money.CurrencyIso.USD

    
    var expenseToTrack: Int = 0 {
        didSet {
            labelForExpenseToTrack.text = "\(currencyToTrack.getCurrencySymbol())\(String(expenseToTrack))"
        }
    }
    
    @IBOutlet weak var labelForExpenseToTrack: UILabel!
    var fetchedResultsController : NSFetchedResultsController?
    
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var categoryPicker: UIPickerView!
   
    var categories: [String]?
    let defaults = NSUserDefaults.standardUserDefaults()
    
    
    
    
    @IBOutlet weak var buttonAdd: CustomAddButton!
   
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        categories = defaults.objectForKey("categories") as? [String]
        
        self.closeButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2/2))
        
        //Location
        locationManager = CLLocationManager()
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        // Get the stack
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let stack = delegate.stack
        
        let fr = NSFetchRequest(entityName: "Expense")
        fr.sortDescriptors = [NSSortDescriptor(key: "value", ascending: true),
                              NSSortDescriptor(key: "date", ascending: false)]
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr,
                                                              managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        
        
        
        //let globalPoint = buttonAdd.superview?.convertPoint(buttonAdd.frame.origin, toView: nil)
        
        
        drawCircle(self.buttonAdd.bounds.width/2, y: self.buttonAdd.bounds.minY-(1*self.buttonAdd.bounds.height/2), radius: 3, color:  UIDesign().blue.colorWithAlphaComponent(1).CGColor)
        drawCircle(self.buttonAdd.bounds.width/2, y: self.buttonAdd.bounds.minY-(2*self.buttonAdd.bounds.height/2), radius: 3, color: UIDesign().blue.colorWithAlphaComponent(0.8).CGColor)
        drawCircle(self.buttonAdd.bounds.width/2, y: self.buttonAdd.bounds.minY-(3*self.buttonAdd.bounds.height/2), radius: 3, color: UIDesign().blue.colorWithAlphaComponent(0.6).CGColor)
        drawCircle(self.buttonAdd.bounds.width/2, y: self.buttonAdd.bounds.minY-(4*self.buttonAdd.bounds.height/2), radius: 3, color: UIDesign().blue.colorWithAlphaComponent(0.4).CGColor)
        drawCircle(self.buttonAdd.bounds.width/2, y: self.buttonAdd.bounds.minY-(5*self.buttonAdd.bounds.height/2), radius: 3, color: UIDesign().blue.colorWithAlphaComponent(0.2).CGColor)

        drawCircle(self.buttonAdd.bounds.width/2, y: self.buttonAdd.bounds.maxY+(1*self.buttonAdd.bounds.height/2), radius: 3, color: UIDesign().blue.colorWithAlphaComponent(1).CGColor)
        drawCircle(self.buttonAdd.bounds.width/2, y: self.buttonAdd.bounds.maxY+(2*self.buttonAdd.bounds.height/2), radius: 3, color: UIDesign().blue.colorWithAlphaComponent(0.8).CGColor)
        drawCircle(self.buttonAdd.bounds.width/2, y: self.buttonAdd.bounds.maxY+(3*self.buttonAdd.bounds.height/2), radius: 3, color: UIDesign().blue.colorWithAlphaComponent(0.6).CGColor)
    }
    
    
    
    func drawCircle(x: CGFloat, y: CGFloat, radius: CGFloat, color: CGColor) {
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x:x, y:y), radius: radius, startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.CGPath

        //change the fill color
        shapeLayer.fillColor = color
        //you can change the stroke color
        shapeLayer.strokeColor = UIColor.clearColor().CGColor
        //you can change the line width
        shapeLayer.lineWidth = 1.0
        buttonAdd.layer.addSublayer(shapeLayer)
    }
    
    
    @IBAction func handlePan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self.view)

        if (recognizer.state == .Changed) {
            if (translation.y < -10) {
            
                expenseToTrack += 1
            
                recognizer.setTranslation(CGPointZero, inView: self.view)

                
            } else if (translation.y > 10) {
        
                expenseToTrack -= 1
                recognizer.setTranslation(CGPointZero, inView: self.view)
            }
        }
        
        if (expenseToTrack < 0) {
            expenseToTrack = 0
        }
        
        
    }
    
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        
        let location = locations.last! as CLLocation
        
        
    }
    
    @IBAction func track(sender: AnyObject) {
    
    
    
        print("we track \(expenseToTrack)")
        
        
        //Initiatlize the money in the currency we want to track
        var moneyToTrack = Money(amount: Double(expenseToTrack), currencyIso: currencyToTrack)
        
        //But now, we want to save the money in the user's currency
        
        //we only need to convert if the currency to track in is different from the users default currency.
        if (currencyToTrack.rawValue != defaults.objectForKey("usersDefaultCurrency") as! String) {
            do {
                let m = Money(amount: 1, currencyIsoString: defaults.objectForKey("usersDefaultCurrency") as! String)
                moneyToTrack = try moneyToTrack.convertMoneyToDifferentCurrency(m.currency!)
                print("DEBUG: successfully converted to EUR")
            } catch {
                //shit
                print("DEBUG: Error while converting to EUR \(error)")
            }
        }
        
        
        // Save tracked expense to the managedObjectContext; Will be made persistent through autosave
        let expense = Expense(value: moneyToTrack.amount, date: NSDate(), context: fetchedResultsController!.managedObjectContext)
        //We just tracked a new expense and set the newCostToTrack back to zero
        expenseToTrack=0
        
        if let location = locationManager.location {
            expense.location = location
            print("yay, we just saved our first location")
        }
        
        //Save category
        let selectedRow = categoryPicker.selectedRowInComponent(0)
        expense.category = pickerView(categoryPicker, titleForRow: selectedRow, forComponent: 0)
        
        //Save currency
        expense.currency = moneyToTrack.currency!.rawValue

        
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("fetch didn't work")
        }
        
        print("current location when track: \(locationManager.location?.coordinate)")
        
        self.dismissViewControllerAnimated(true, completion: ({
                NSNotificationCenter.defaultCenter().postNotificationName("AddExpenseModalDismissed", object: nil)
    
        }))
    }
    
    
    //Picker delegate functions
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return categories!.count
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return categories![row]
        
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.whiteColor()
        pickerLabel.text = categories![row]
        pickerLabel.font = UIFont(name: ".SFUIText-Regular", size: 12)!
        pickerLabel.textAlignment = NSTextAlignment.Center
        return pickerLabel
    }
    

}