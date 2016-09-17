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
    
    enum CallBackActions {
        case changeDefaultCurrency
        case changeCurrencyToTrack
    }
    
    var callBackAction: CallBackActions?
    
    @IBOutlet weak var currencyPicker: UIPickerView!
    var selectedCurrency: String = ""
    
    @IBOutlet weak var messageLabel: UILabel!
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var closeButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Make modal windo transparent
        view.backgroundColor = UIDesign().darkBlue.withAlphaComponent(0.8)
        view.isOpaque = false
        roundedCornersView.layer.cornerRadius = 30
        self.closeButton.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2/2))
        
        let m = Money(amount: 1, currencyIsoString: defaults.object(forKey: "usersDefaultCurrency") as! String)
        let defaultRowIndex = currencies.index(of: m.currency!)
        currencyPicker.selectRow(defaultRowIndex!, inComponent: 0, animated: true)
        
    }
    
    
    @IBAction func closeModal(_ sender: AnyObject) {
        self.dismiss(animated: false, completion: nil)
    }
    @IBAction func OK(_ sender: AnyObject) {
        self.dismiss(animated: false, completion: nil)
        let object:[AnyObject] = [self.selectedCurrency as AnyObject]
        
        if let callBackAction = callBackAction {
            switch callBackAction {
            case .changeCurrencyToTrack :
                NotificationCenter.default.post(name: Notification.Name(rawValue: "ChangeCurrencyToTrack"), object: object)
            case .changeDefaultCurrency :
                NotificationCenter.default.post(name: Notification.Name(rawValue: "ChangeDefaultCurrency"), object: object)
            default: break
            }
        }
        
    }
    
}

//PickerView Delegates
extension ChooseCurrencyViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencies.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencies[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIDesign().darkBlue
        pickerLabel.text = "\(currencies[row].rawValue) (\(currencies[row].getCurrencySymbol()))"
        //pickerLabel.font = UIFont(name: ".SFUIText-Regular", size: 18)!
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCurrency = currencies[row].rawValue
        print("just selected currency: \(selectedCurrency)")
    }
    
}
