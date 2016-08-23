//
//  Currency.swift
//  spave
//
//  Created by Dominik Faber on 19.08.16.
//  Copyright © 2016 granolahouse. All rights reserved.
//

import Foundation



struct Money {
    let defaults = NSUserDefaults.standardUserDefaults()
    
    enum MoneyErrorType: ErrorType {
        case AnyError
    }
   
    
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
        
        static let allValues = [EUR, USD, JPY,GBP, AUD, CHF, CAD, MXN, CNY, NZD, SEK, RUB, HKD, NOK, SGD, TRY, KRW, ZAR, BRL, INR]
        
        func getCurrencySymbol() -> String {
            switch self {
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
    
    var currency:CurrencyIso?
    var amount: Double
    
    func getDefaultCurrencyAsSymbol() -> String {
        //Todo
        return "$"
    }
    
    
    
    init(amount: Double, currencyIso: CurrencyIso) {
        self.amount = amount
        self.currency = currencyIso
    }
    
    init(amount: Double, currencyIsoString: String) {
        self.amount = amount
        
        if let currencyAsIso = Money.CurrencyIso(rawValue: currencyIsoString) {
            self.currency = currencyAsIso
        } else {
            self.currency = .USD
        }
    }
    
    func getCurrencyExchangeRatesFromWebService() throws -> [String: AnyObject] {
        //Todo
        var currencyStringForURL = ""
        
        // load currencies from web service
        for currency in CurrencyIso.allValues{
            currencyStringForURL = currencyStringForURL+","+currency.rawValue
        }
        
        let requestURL: NSURL = NSURL(string: "https://api.fixer.io/latest?symbols=\(currencyStringForURL)")!
        let data = NSData(contentsOfURL: requestURL)
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments) as! [String: AnyObject]
            
            print("successfully loaded rates from the webservice fixer.io")
            return json["rates"] as! [String: AnyObject]
        } catch {
            print("error loading the rates from the webservice")
            throw error
        }
    }
    
    func getCurrencyExchangeRateBasedOnEUR(currencyIso: CurrencyIso) throws -> Double? {
        var rates: [String: AnyObject]
        
        do {
            rates = try getCurrencyExchangeRatesFromWebService()
            print("Rates array: \(rates)")
            for (currency, rate) in rates {
                print("Iterating through the rates array: \(currency)")
                if currency == currencyIso.rawValue {
                    print("getCurrencyExchangeRateBasedOnEUR for \(currencyIso.rawValue): \(rate as? Double) ")
                    return rate as? Double
                }
            }
        } catch {
                throw error
        }
        return nil
    }
    
    func persistCurrencyExchangeRates() {
        
        //todo: load currency exchange rates from web service and persist in coredata
        
    }
    
    mutating func convertMoneyToDifferentCurrency(newCurrency: CurrencyIso) throws -> Money {
        /* Todo
         Convert money to EUR
         convert moneyInEUR to new currency
         return converted money
         */
        

            //First: Convert moneyToTrack to EUR as we only have the currency exchange rates based to EUR
            if (currency != .EUR) {
                print("We need to convert to EUR first")
                //We only need to convert to EUR if it's not already in EUR
                do {
                    let exchangeRateEUR = try getCurrencyExchangeRateBasedOnEUR(self.currency!)
                    print("EUR -> \(self.currency!.rawValue): \(exchangeRateEUR)")
                    
                    self = Money(amount: amount / exchangeRateEUR!, currencyIso: .EUR)
                    print("››››› \(self)")
                    
                } catch {
                    //shit
                    print("DEBUG: Error while converting to EUR \(error)")
                }
            }
            
            //Second: Convert moneyToTrack to the users default currency
            
            print("DEBUG: We need to convert to the users default currency")
            do {
                let exchangeRateNew = try getCurrencyExchangeRateBasedOnEUR(newCurrency)
                self = Money(amount: amount * exchangeRateNew!, currencyIso: newCurrency)
                print("DEBUG: successfully converted to \(newCurrency.rawValue) \(self)")
                
            } catch {
                //shit
            }

        
        return self
    }
        
    
    
    
    
}