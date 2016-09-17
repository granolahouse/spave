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
    
    let defaults = UserDefaults.standard

    
    
    var currencyToTrack = Money.CurrencyIso.USD {
        didSet {
            labelForExpenseToTrack.text = "\(currencyToTrack.getCurrencySymbol())\(String(expenseToTrack))"
        }
    }

    
    var expenseToTrack: Int = 0 {
        didSet {
            labelForExpenseToTrack.text = "\(currencyToTrack.getCurrencySymbol())\(String(expenseToTrack))"
        }
    }
    
    @IBOutlet weak var labelForExpenseToTrack: UILabel!
    var fetchedResultsController : NSFetchedResultsController<Expense>?
    
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var categoryPicker: UIPickerView!
   
    var categories: [String]?
    
    
    
    
    @IBOutlet weak var buttonAdd: CustomAddButton!
   
    override func viewDidLoad() {
        
        super.viewDidLoad()
      
        
        let defaultCurrency = defaults.object(forKey: "usersDefaultCurrency") as! String
        currencyToTrack = Money(amount: 1, currencyIsoString: defaultCurrency).currency!
        
         NotificationCenter.default.addObserver(self, selector: #selector(AddExpenseViewController.changeCurrencyToTrack), name:NSNotification.Name(rawValue: "ChangeCurrencyToTrack"), object: nil)
        
        
        categories = defaults.object(forKey: "categories") as? [String]
        categories = categories!.sorted(by: {$0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending})
        
        self.closeButton.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2/2))
        
        //Location
        locationManager = CLLocationManager()
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        // Get the stack
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Expense")
        fr.sortDescriptors = [NSSortDescriptor(key: "value", ascending: true),
                              NSSortDescriptor(key: "date", ascending: false)]
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr as! NSFetchRequest<Expense>,
                                                              managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        
        
        
        //let globalPoint = buttonAdd.superview?.convertPoint(buttonAdd.frame.origin, toView: nil)
        
        
        drawCircle(self.buttonAdd.bounds.width/2, y: self.buttonAdd.bounds.minY-(1*self.buttonAdd.bounds.height/2), radius: 3, color:  UIDesign().blue.withAlphaComponent(1).cgColor)
        drawCircle(self.buttonAdd.bounds.width/2, y: self.buttonAdd.bounds.minY-(2*self.buttonAdd.bounds.height/2), radius: 3, color: UIDesign().blue.withAlphaComponent(0.8).cgColor)
        drawCircle(self.buttonAdd.bounds.width/2, y: self.buttonAdd.bounds.minY-(3*self.buttonAdd.bounds.height/2), radius: 3, color: UIDesign().blue.withAlphaComponent(0.6).cgColor)
        drawCircle(self.buttonAdd.bounds.width/2, y: self.buttonAdd.bounds.minY-(4*self.buttonAdd.bounds.height/2), radius: 3, color: UIDesign().blue.withAlphaComponent(0.4).cgColor)
        drawCircle(self.buttonAdd.bounds.width/2, y: self.buttonAdd.bounds.minY-(5*self.buttonAdd.bounds.height/2), radius: 3, color: UIDesign().blue.withAlphaComponent(0.2).cgColor)

        drawCircle(self.buttonAdd.bounds.width/2, y: self.buttonAdd.bounds.maxY+(1*self.buttonAdd.bounds.height/2), radius: 3, color: UIDesign().blue.withAlphaComponent(1).cgColor)
        drawCircle(self.buttonAdd.bounds.width/2, y: self.buttonAdd.bounds.maxY+(2*self.buttonAdd.bounds.height/2), radius: 3, color: UIDesign().blue.withAlphaComponent(0.8).cgColor)
        drawCircle(self.buttonAdd.bounds.width/2, y: self.buttonAdd.bounds.maxY+(3*self.buttonAdd.bounds.height/2), radius: 3, color: UIDesign().blue.withAlphaComponent(0.6).cgColor)
    }
    
    
    
    func drawCircle(_ x: CGFloat, y: CGFloat, radius: CGFloat, color: CGColor) {
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x:x, y:y), radius: radius, startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath

        //change the fill color
        shapeLayer.fillColor = color
        //you can change the stroke color
        shapeLayer.strokeColor = UIColor.clear.cgColor
        //you can change the line width
        shapeLayer.lineWidth = 1.0
        buttonAdd.layer.addSublayer(shapeLayer)
    }
    
    
    @IBAction func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        let velocity = recognizer.velocity(in: self.view)
        
        if (recognizer.state == .changed) {
            if (translation.y < -10) {
                
                if (-velocity.y > 500) {
                    //super fast speed
                    expenseToTrack += 10
                } else {
                    //normal speed
                    expenseToTrack += 1
                }
                
                recognizer.setTranslation(CGPoint.zero, in: self.view)

                
            } else if (translation.y > 10) {
        
                
                if (velocity.y > 500) {
                    //super fast speed
                    expenseToTrack -= 10
                } else {
                    //normal speed
                    expenseToTrack -= 1
                }
                recognizer.setTranslation(CGPoint.zero, in: self.view)
            }
        }
        
        if (expenseToTrack < 0) {
            expenseToTrack = 0
        }
        
        
    }
    
    
    @IBAction func cancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        
        let location = locations.last! as CLLocation
        
        
    }
    
    func changeCurrencyToTrack(_ notification:Notification) {
        if let changedCurrency = notification.object as? [String] {
            currencyToTrack = Money(amount: 1, currencyIsoString: changedCurrency[0]).currency!
        }
        print("received choosen currency: \(currencyToTrack)")
    }
    
    @IBAction func track(_ sender: AnyObject) {
    
        print("we track \(expenseToTrack)")

        //Initiatlize the money in the currency we want to track
        var moneyToTrack = Money(amount: NSDecimalNumber(value: expenseToTrack as Int), currencyIso: currencyToTrack)
        
        //But now, we want to save the money in the user's currency
        
        //we only need to convert if the currency to track in is different from the users default currency.
        if (currencyToTrack.rawValue != defaults.object(forKey: "usersDefaultCurrency") as! String) {
            do {
                let m = Money(amount: 1, currencyIsoString: defaults.object(forKey: "usersDefaultCurrency") as! String)
                moneyToTrack = try moneyToTrack.convertMoneyToDifferentCurrency(m.currency!)
                print("DEBUG: successfully converted to \(m.currency!.rawValue) which is \(moneyToTrack.amount)")
            } catch {
                //shit
                print("DEBUG: Error while converting to EUR \(error)")
            }
        }
        
        
        // Save tracked expense to the managedObjectContext; Will be made persistent through autosave
        let expense = Expense(value: moneyToTrack.amount, date: Date(), context: fetchedResultsController!.managedObjectContext)
        //We just tracked a new expense and set the newCostToTrack back to zero
        expenseToTrack=0
        
        if let location = locationManager.location {
            expense.location = location
            print("yay, we just saved our first location")
        }
        
        //Save category
        let selectedRow = categoryPicker.selectedRow(inComponent: 0)
        expense.category = pickerView(categoryPicker, titleForRow: selectedRow, forComponent: 0)
        
        //Save currency
        expense.currency = moneyToTrack.currency!.rawValue

        
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("fetch didn't work")
        }
        
        print("current location when track: \(locationManager.location?.coordinate)")
        
        self.dismiss(animated: true, completion: ({
            NotificationCenter.default.post(name: Notification.Name(rawValue: "AddExpenseModalDismissed"), object: nil)
    
        }))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! ChooseCurrencyViewController
        vc.callBackAction = .changeCurrencyToTrack
    }
    
    
    //Picker delegate functions
    func numberOfComponentsInPickerView(_ pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return categories!.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return categories![row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.white
        pickerLabel.text = categories![row]
        
        //pickerLabel.font = UIFont(name: ".SFUIText-Regular", size: 12)!
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }
    

}
