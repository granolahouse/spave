//
//  ChooseCurrencyViewController.swift
//  spave
//
//  Created by Dominik Faber on 24.08.16.
//  Copyright © 2016 granolahouse. All rights reserved.
//

import Foundation
import UIKit
@IBDesignable
class ChooseCurrencyViewController: UIViewController {
    
    @IBOutlet weak var roundedCornersView: UIView!
    var currencies: [Money.CurrencyIso] = Money.CurrencyIso.allValues
    
    @IBOutlet weak var currencyPicker: UIPickerView!
    var selectedCurrency: String = ""
    
    @IBOutlet weak var messageLabel: UILabel!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var closeButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Make modal windo transparent
        view.backgroundColor = UIDesign().darkBlue.colorWithAlphaComponent(0.8)
        view.opaque = false
        roundedCornersView.layer.cornerRadius = 30
        self.closeButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2/2))
        
        let m = Money(amount: 1, currencyIsoString: defaults.objectForKey("usersDefaultCurrency") as! String)
        let defaultRowIndex = currencies.indexOf(m.currency!)
        currencyPicker.selectRow(defaultRowIndex!, inComponent: 0, animated: true)
        
    }
    @IBAction func closeModal(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    @IBAction func OK(sender: AnyObject) {
        
        let object:[AnyObject] = [selectedCurrency]
        NSNotificationCenter.defaultCenter().postNotificationName("ChangeCurrencyToTrack", object: object)
        self.dismissViewControllerAnimated(false, completion: nil)
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
        return currencies[row].rawValue
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.blackColor()
        pickerLabel.text = "\(currencies[row].rawValue) (\(currencies[row].getCurrencySymbol()))"
        pickerLabel.font = UIFont(name: ".SFUIText-Regular", size: 12)!
        pickerLabel.textAlignment = NSTextAlignment.Center
        return pickerLabel
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCurrency = currencies[row].rawValue
        print("just selected currency: \(selectedCurrency)")
    }
    
}
