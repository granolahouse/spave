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
        
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        
        let defaults = UserDefaults.standard
        categories = defaults.object(forKey: "categories") as? [String]
        categories = categories!.sorted(by: {$0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending})
        

        print(categories)
        
        descriptionTextfield.delegate = self
        
        if let expense = expense {
            
            //Load Date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE, h:s a"
            let humanReadableExpenseDate = dateFormatter.string(from: expense.date! as Date)
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
                self.map.isHidden = true
            }
            
            //Load Category
            if let defaultCategory = expense.category {
                
                if let defaultRowIndex = categories!.index(of: defaultCategory) {
                    categoryPicker.selectRow(defaultRowIndex, inComponent: 0, animated: true)
                }
            }
            
            var money: Money?
            
            //Load Expense
            if let currency = expense.currency {
                money = Money(amount: expense.value!, currencyIsoString: currency)
            } else {
                let defaultCurrency = defaults.object(forKey: "usersDefaultCurrency") as! String
                money = Money(amount: expense.value!, currencyIsoString: defaultCurrency)
            }
            
            let formatter = NumberFormatter()
            formatter.currencyCode = money!.currency!.rawValue
            formatter.numberStyle = .currencyAccounting
            formatter.maximumFractionDigits = 0
            label.text = formatter.string(from: money!.amount)

            
        }
        
    }
    
    //Textfield delegates
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("textfield left")
        if let expense = expense {
            expense.desc = textField.text
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("return")
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //Picker delegates
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return categories!.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return categories![row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIDesign().darkBlue
        pickerLabel.text = categories![row]
        //pickerLabel.font = UIFont(name: ".SFUIText-Regular", size: 12)!
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        expense!.category = categories![row]
    }

    
    
}
