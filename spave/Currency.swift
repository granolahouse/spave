//
//  Currency.swift
//  spave
//
//  Created by Dominik Faber on 19.08.16.
//  Copyright © 2016 granolahouse. All rights reserved.
//

import Foundation


struct Currency {
    let defaults = NSUserDefaults.standardUserDefaults()
    
    
    
    enum CurrencyIso:String {
        case EUR = "EUR"
        case USD = "USD"
        case JPY = "JPY"
        case GBP = "GBP"
        case AUD = "AUD"
        case CHF = "CHF"
        case CAD = "CAD"
        case MXN = "MXN"
        case CNY = "CNY"
        case NZD = "NZD"
        case SEK = "SEK"
        case RUB = "RUB"
        case HKD = "HKD"
        case NOK = "NOK"
        case SGD = "SGD"
        case TRY = "TRY"
        case KRW = "KRW"
        case ZAR = "ZRW"
        case BRL = "BRL"
        case INR = "INR"
    }
    
    var currency:CurrencyIso?
    
    func getDefaultCurrencyAsSymbol() -> String {
      return "$"
    }
    
    
    
    init(currencyIso: CurrencyIso) {
        self.currency = currencyIso
    }
    
    init(currencyIsoString: String) {
        if let currencyAsIso = Currency.CurrencyIso(rawValue: currencyIsoString) {
            self.currency = currencyAsIso
        } else {
            self.currency = .USD
        }
    }
    
    
    func getSymbol() -> String {
        switch currency! {
        case .EUR :
            return "€"
        case .USD :
            return "$"
        case .JPY :
            return "¥"
        case .GBP :
            return "£"
        case .AUD :
            return "$"
        case .CHF :
            return "Fr"
        case .CAD :
            return "$"
        case .MXN :
            return "$"
        case .CNY :
            return "¥"
        case .NZD :
            return "$"
        case .SEK :
            return "kr"
        case .RUB :
            return "₽"
        case .HKD :
            return "$"
        case .NOK :
            return "kr"
        case .SGD :
            return "$"
        case .TRY :
            return "₺"
        case .KRW :
            return "₩"
        case .ZAR :
            return "R"
        case .BRL :
            return "R$"
        case .INR :
            return "₹"
        }
    }
}