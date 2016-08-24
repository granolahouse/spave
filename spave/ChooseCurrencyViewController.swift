//
//  ChooseCurrencyViewController.swift
//  spave
//
//  Created by Dominik Faber on 24.08.16.
//  Copyright © 2016 granolahouse. All rights reserved.
//

import Foundation
import UIKit

class ChooseCurrencyViewController: UIViewController {
    
    let currencies = ["EUR", "USD"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

//PickerView Delegates
extension ChooseCurrencyViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencies.count
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencies[row]
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.blackColor()
        pickerLabel.text = currencies[row]
        pickerLabel.font = UIFont(name: ".SFUIText-Regular", size: 12)!
        pickerLabel.textAlignment = NSTextAlignment.Center
        return pickerLabel
    }
    
}