//
//  SpendingViewController.swift
//  kaching
//
//  Created by Dominik Faber on 01.08.16.
//  Copyright © 2016 Dominik Faber. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class SpendingViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var map: MKMapView!
    var expense: Expense?
    
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionTextfield: UITextField!
    
    @IBOutlet weak var categoryPicker: UIPickerView!
    var categories: [String]?
    
    override func viewDidLoad() {
        
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        
        let defaults = NSUserDefaults.standardUserDefaults()
        categories = defaults.objectForKey("categories") as? [String]
        print(categories)
        
        descriptionTextfield.delegate = self
        
        if let expense = expense {
            
            //Load Date
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "EEEE, h:s a"
            let humanReadableExpenseDate = dateFormatter.stringFromDate(expense.date!)
            dateLabel.text = humanReadableExpenseDate
            
            
            
            //Load Description
            if let desc = expense.desc {
                descriptionTextfield.text = desc
            }
            
            // LoadLocation
            if let locationSet = expense.location {
                let location = locationSet as! CLLocation
                let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                self.map.setRegion(region, animated: true)
            
                let pinLocation : CLLocationCoordinate2D = location.coordinate
                let objectAnnotation = MKPointAnnotation()
                objectAnnotation.coordinate = pinLocation
                objectAnnotation.title = "test"
                self.map.addAnnotation(objectAnnotation)
            } else {
                //No location set
                self.map.hidden = true
            }
            
            //Load Category
            if let defaultCategory = expense.category {
                
                let defaultRowIndex = categories!.indexOf(defaultCategory)
                categoryPicker.selectRow(defaultRowIndex!, inComponent: 0, animated: true)
            }
            
            //Load Expense
            
            // Display expense
            var currency: Currency = Currency(currencyIso: .USD)
            if let currencyAsString = expense.currency {
                
                currency = Currency(currencyIsoString: currencyAsString)
            }
            
            label.text = String("\(currency.getSymbol())\(expense.value!)")
            
        }
        
    }
    
    //Textfield delegates
    func textFieldDidEndEditing(textField: UITextField) {
        print("textfield left")
        if let expense = expense {
            expense.desc = textField.text
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        print("return")
        return true
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //Picker delegates
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
        pickerLabel.textColor = UIDesign().darkBlue
        pickerLabel.text = categories![row]
        pickerLabel.font = UIFont(name: ".SFUIText-Regular", size: 12)!
        pickerLabel.textAlignment = NSTextAlignment.Center
        return pickerLabel
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        expense!.category = categories![row]
    }

    
    
}