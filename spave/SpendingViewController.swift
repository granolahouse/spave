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

class SpendingViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var map: MKMapView!
    var expense: Expense?
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionTextfield: UITextField!
    
    
    override func viewDidLoad() {
        
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        
        
        descriptionTextfield.delegate = self
        
        if let expense = expense {
            
            //Date
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "EEEE, h:s a"
            let humanReadableExpenseDate = dateFormatter.stringFromDate(expense.date!)
            dateLabel.text = humanReadableExpenseDate
            
            
            
            //Description
            if let desc = expense.desc {
                descriptionTextfield.text = desc
            }
            
            //Location
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
            
            label.text = String("€\(expense.value!)")
            
        }
        
    }
    
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
    
    
}