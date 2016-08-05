//
//  CategoryPickerDelegate.swift
//  spave
//
//  Created by Dominik Faber on 05.08.16.
//  Copyright © 2016 granolahouse. All rights reserved.
//

import Foundation
import UIKit

class CategoryPickerDelegate: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let pickerValues = ["misc", "food", "fun"]
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerValues.count
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerValues[row]
    }
    
    
}