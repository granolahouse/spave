//
//  AppDelegate.swift
//  kaching
//
//  Created by Dominik Faber on 21.07.16.
//  Copyright © 2016 Dominik Faber. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    let stack = CoreDataStack(modelName: "Model")!
    let categories = ["Misc", "Mobility", "Food", "Groceries", "Drinks", "Restaurant", "Friends", "Entertainment", "Free time", "Clothes", "Education", "Kids", "Pets", "Hobby", "Health"]
    
    func resetDatabase(){
        
        // Remove previous stuff (if any)
        do{
            try stack.dropAllData()
        }catch{
            print("Error droping all objects in DB")
        }
        
        
        // create a few expenses to test
        //let expense1 = Expense(value: 12, context: stack.context)
        //let expense2 = Expense(value: 15, context: stack.context)
        //let expense3 = Expense(value: 3, context: stack.context)
        
        
    }
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        
        //Settings with user defaults
        let defaults = UserDefaults.standard
        
        
        
        
        if defaults.bool(forKey: "appLaunchedFirstTime") {
            
            
            
            
            
            
            if defaults.object(forKey: "categories") == nil || defaults.object(forKey: "categories") as! [String] != categories {
                defaults.set(categories, forKey: "categories")
            }
            
            if defaults.object(forKey: "usersDefaultCurrency") == nil {
                defaults.set(Money.CurrencyIso.USD.rawValue, forKey: "usersDefaultCurrency")
            }
            
            if defaults.double(forKey: "monthlyBudget") == 0 {
                defaults.set(800, forKey: "monthlyBudget")
            }
            if defaults.double(forKey: "savingsGoal") == 0 {
                defaults.set(60, forKey: "savingsGoal")
            }
            
            //exchange Rates
            if defaults.object(forKey: "currencyExchangeRates") == nil {
                //load exchange rates
                var rates: [String: AnyObject]
                do {
                    let m = Money(amount: 1, currencyIso: .EUR)
                    rates = try m.getCurrencyExchangeRatesFromWebService()
                    defaults.set(rates, forKey: "currencyExchangeRates")
                } catch {
                    //shit - We could load some example rates instead?
                }
            }
            
        } else {
            //app was launched the first time, so we create some NSDefaults and set their default
            defaults.set(true, forKey: "appLaunchedFirstTime")
            
            //Categories
            defaults.set(categories, forKey: "categories")
            
            //Monthly budget
            defaults.set(800, forKey: "monthlyBudget")
            defaults.set(60, forKey: "savingsGoal")

            
            //defaults.setInteger(800, forKey: "monthlyBudget")
            //defaults.setInteger(60, forKey: "savingsGoal")
            
            //Users default currency
            defaults.set(Money.CurrencyIso.USD.rawValue, forKey: "usersDefaultCurrency")
            
            //exchange Rates
            
            //load exchange rates
            var rates: [String: AnyObject]
            do {
                let m = Money(amount: 1, currencyIso: .EUR)
                rates = try m.getCurrencyExchangeRatesFromWebService()
                defaults.set(rates, forKey: "currencyExchangeRates")
            } catch {
                //shit - We could load some example rates instead?
            }
            
            
           
            
        }
        
                
        // Load some notebooks and notes.
        //preloadData()
        
        
        
        // Start Autosaving
        stack.autoSave(5)
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        stack.save()
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        stack.save()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

