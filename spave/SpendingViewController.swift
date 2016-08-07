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

class SpendingViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var map: MKMapView!
    var expense: Expense?
    
    
    override func viewDidAppear(animated: Bool) {
        
        
        
        if let expense = expense {
            
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
}