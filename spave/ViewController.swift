//
//  ViewController.swift
//  kaching
//
//  Created by Dominik Faber on 05.07.16.
//  Copyright © 2016 Dominik Faber. All rights reserved.
//

import UIKit
import CoreData
import Charts
import CoreLocation
@IBDesignable

class ViewController: UIViewController {
    
    @IBOutlet weak var labelForCost: UILabel!
    
    @IBOutlet weak var buttonToTrack: UIButton!
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var labelForSavingsGoal: UILabel!
    @IBOutlet weak var labelForSpentToday: UILabel!
    @IBOutlet weak var labelForSpentThisWeek: UILabel!
    @IBOutlet weak var customProgressBar: CustomProgressRing!
    
    @IBOutlet weak var labelForSpendingToTrack: UILabel!
    @IBOutlet weak var labelForCategory: UILabel!
    @IBOutlet weak var fieldForCategory: UILabel!
    @IBOutlet weak var labelForSpentThisWeek2: UILabel!
    @IBOutlet weak var labelForSpentToday2: UILabel!
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var viewForSpentToday: UIView!
    
    @IBOutlet weak var seperatorLine: CustomSeperatorLine!
    @IBOutlet weak var viewLeftNumber: UIView!
    @IBOutlet weak var buttonForSpendings: UIBarButtonItem!
    let defaults = NSUserDefaults.standardUserDefaults()
    let blue = UIColor(red: 60/255, green: 176/255, blue: 226/255, alpha: 1.0)
    let pink = UIColor(red: 226/255, green: 60/255, blue: 105/255, alpha: 1.0)
    let darkBlue = UIColor(red: 41/255, green: 52/255, blue: 72/255, alpha: 1.0)
    let ll: ChartLimitLine = ChartLimitLine()
    
    var numbersOfDaysInCurrentMonth: Int {
        //Numbers of days of current month
        let calendar = NSCalendar.currentCalendar()
        return calendar.component([.Day], fromDate: NSDate().endOfMonth())
    }
    
    
    
    var totalCostOfTheDay: Int = 0
    var dailyLimit: Int = 6
    var daysForBarChart: [String] = []
    var monthlyBudget: Money!
    var formatter: NSNumberFormatter = NSNumberFormatter()
    
    
    
    var valueForLabelSpentToday: NSDecimalNumber = 0 {
        didSet {
            let money = Money(amount: valueForLabelSpentToday, currencyIsoString: defaults.objectForKey("usersDefaultCurrency") as! String)
            labelForSpentToday.text = formatter.stringFromNumber(money.amount)
        }
    }
    
    var valueForLabelSpentThisWeek: NSDecimalNumber = 0 {
        didSet {
            let money = Money(amount: valueForLabelSpentThisWeek, currencyIsoString: defaults.objectForKey("usersDefaultCurrency") as! String)
            labelForSpentThisWeek.text = formatter.stringFromNumber(money.amount)
        }
    }
    
    var savedThisMonth: NSDecimalNumber = 0 {
        didSet {
            let money = Money(amount: savedThisMonth, currencyIsoString: defaults.objectForKey("usersDefaultCurrency") as! String)
            let currencySymbol = Money(amount: 1, currencyIsoString: defaults.objectForKey("usersDefaultCurrency") as! String).currency!.getCurrencySymbol()
            labelForSavingsGoal.text = formatter.stringFromNumber(savedThisMonth)
            customProgressBar.savingsGoal = Int(defaults.doubleForKey("savingsGoal"))
            customProgressBar.counter = savedThisMonth.doubleValue
        }
    }
    
    var savingsGoal: Money?
    
    // MARK:  - Properties
    var fetchedResultsController : NSFetchedResultsController?
    
    

    
    
    
    override func viewDidAppear(animated: Bool) {
        
        
        //Load user defaults
        savingsGoal = Money(amount: NSDecimalNumber(double: defaults.doubleForKey("savingsGoal")),
                            currencyIsoString: defaults.objectForKey("usersDefaultCurrency") as! String)
        
        
        monthlyBudget = Money(amount: NSDecimalNumber(double: defaults.doubleForKey("monthlyBudget")),
                              currencyIsoString: defaults.objectForKey("usersDefaultCurrency") as! String)
        
        print(monthlyBudget)

        
        
        //ll = ChartLimitLine(limit: dailyLimit, label: "")
        
        barChartView.leftAxis.addLimitLine(ll)

        
        customProgressBar.savingsGoal = savingsGoal!.amount.integerValue
        
        //Some UI changes
        customProgressBar.backgroundColor = UIColor.clearColor()
        let font = UIFont(name: ".SFUIText-Regular", size: 14)!
        buttonForSpendings.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
        
        
        
        
        
        
        //UIBarButtonItem.appearance().setBackButtonBackgroundImage(backImg, forState: .Normal, barMetrics: .Default)
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "BackIcon")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "BackIcon")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.tintColor = UIDesign().lightGrey
        
        let navBar = navigationController!.navigationBar
        
        
        navBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navBar.shadowImage = UIImage()
        navBar.translucent = true
        
        
        
        //navBarColor.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        
        // Get the stack
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let stack = delegate.stack
        
        
        //Create fetch request to load the saved expenses
        let fr = NSFetchRequest(entityName: "Expense")
        fr.sortDescriptors = [NSSortDescriptor(key: "value", ascending: true),
                              NSSortDescriptor(key: "date", ascending: false)]
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr,
                                                              managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        
        
        barChartView.noDataTextDescription = "No data yet. Start tracking by adding your expenses"
        
       
        
        //Check if the user opens the app for the first time. If so, show onboarding
        
        if defaults.boolForKey("UserHasSeenOnboarding") {
            //Do nothing
        } else {
            let onboardingController = self.storyboard?.instantiateViewControllerWithIdentifier("Onboarding") as! OnboardingPageViewController
            self.presentViewController(onboardingController, animated: true, completion: nil)
        }

        
        
        
        //Check if database seems to by empty, then fire up a modal to ask the user to enter the spent money this month to populate the database with it
        let spendingsEver = spentInDateInterval(NSDate().dateOfDaysBeforeOrAfter(-20000).startOfDay, endDate: NSDate().dateOfDaysBeforeOrAfter(0).endOfDay!)
        let numberOfDaysSinceStartOfMonth = NSDate().daysBetweenDates(NSDate().startOfMonth(), endDate: NSDate())
        
        print("Number of days since start of month: \(numberOfDaysSinceStartOfMonth)")
        
        if (spendingsEver == 0) && (numberOfDaysSinceStartOfMonth != 0) {
            
            
            
            let calendar = NSCalendar.currentCalendar()
            let components = calendar.components([.Day , .Month , .Year], fromDate: NSDate())
            
            
            let month = components.month
            let monthName = NSDateFormatter().monthSymbols[month - 1]
            
            let alert = UIAlertController(title: "Howdy", message: "Looks like you are using the app the very first time or dropped all your data. Please enter the amount of money you've already spent this month (\(monthName)). If you don't know, just estimate and trust your gut feeling.", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "Save", style: UIAlertActionStyle.Default, handler: {(UIAlertAction) -> Void in
                
                //Number of days since begin of month
                
                var x = 0
                let currency = self.defaults.objectForKey("usersDefaultCurrency") as! String
                //spendings until now, estimated by the user
                if let spendingsUntilNow = Int(alert.textFields![0].text!) {
                    
                    //Fill database with estimated spendings
                    while x < numberOfDaysSinceStartOfMonth {
                        var expenseToTrack = Expense(value: NSDecimalNumber(integer:spendingsUntilNow/numberOfDaysSinceStartOfMonth), date: NSDate().dateOfDaysBeforeOrAfter(-1*numberOfDaysSinceStartOfMonth+x), context: self.self.fetchedResultsController!.managedObjectContext)
                        expenseToTrack.currency = currency
                        x+=1
                    }
                }
                self.self.drawSpendingsOverviewChart()
                self.self.viewDidAppear(false)
                
            }))
            
            alert.addTextFieldWithConfigurationHandler({(UITextField) -> Void in
                let textField = UITextField
                
                textField.text="0"
                
            })
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        
        
         updateUI()
    
    }
    

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        

        formatter.numberStyle = .CurrencyAccountingStyle
        formatter.maximumFractionDigits = 0
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(ViewController.updateUI), name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.updateUI), name:"AddExpenseModalDismissed", object: nil)
        
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    
    
    func updateUI() {
        
        let currency = Money(amount: 1, currencyIsoString: defaults.objectForKey("usersDefaultCurrency") as! String).currency!
        
        let formatter = NSNumberFormatter()
        formatter.currencyCode = currency.rawValue
        formatter.numberStyle = .CurrencyAccountingStyle
        formatter.roundingMode = .RoundHalfEven
        formatter.maximumFractionDigits = 0
        

        
        valueForLabelSpentToday = spentInDateInterval(NSDate().startOfDay, endDate: NSDate().endOfDay!)
        valueForLabelSpentThisWeek = spentInDateInterval(NSDate().startOfWeek, endDate: NSDate().endOfDay!)
        savedThisMonth = calculateSavingsThisMonth()
        customProgressBar.savingsGoal = Int(defaults.doubleForKey("savingsGoal"))
        
        
        // Update labels
        labelForSpentToday.text = formatter.stringFromNumber(valueForLabelSpentToday)
        labelForSpentThisWeek.text = formatter.stringFromNumber(valueForLabelSpentThisWeek)
        labelForSavingsGoal.text = formatter.stringFromNumber(savedThisMonth)
        customProgressBar.counter = savedThisMonth.doubleValue
        
        // Update chart
        drawSpendingsOverviewChart()
    }
    
    // func spentThisWeek()
    // Query - Get all tracked expenses for the week - predicate: %@ <= date AND date <= %@
    // Sum the expenses
    // Create Fetch Request
    // return what we spent today
    func spentInDateInterval(startDate: NSDate, endDate: NSDate) -> NSDecimalNumber {
        
        var spent: NSDecimalNumber = 0
        let expensesFetch = NSFetchRequest(entityName: "Expense")
        expensesFetch.predicate = NSPredicate(format: "%@ <= date AND date <= %@", startDate, endDate)
        
        do {
            let fetchedExpenses = try fetchedResultsController!.managedObjectContext.executeFetchRequest(expensesFetch) as! [Expense]
            for expense in fetchedExpenses {
                spent = spent.decimalNumberByAdding(expense.value!)
            }
        } catch {
            fatalError("Failed to fetch expenses: \(error)")
        }
        
        return spent
    }
    
    
    func calculateSavingsThisMonth() -> NSDecimalNumber {
        
        //Algorithm: monthlyBudget - spentThisMonth + (numberOfDaysUntilEndOfMonth*dailyBudget)
        
        //numberOfDaysUntilEndOfMonth - get the number of days until end of month
        
        
        let numberOfDaysUntilEndOfMonth = NSDate().daysBetweenDates(NSDate(), endDate: NSDate().endOfMonth())
        print("debug for Calculate savings: numberOfDaysUntilEndOfMonth = \(numberOfDaysUntilEndOfMonth)")
        let spentThisMonth = spentInDateInterval(NSDate().startOfMonth(), endDate: NSDate())
        
        
        
        let monthlyBudgetAsDouble: Double = defaults.doubleForKey("monthlyBudget")
        print("debug for Calculate savings: monthlyBudget = \(monthlyBudgetAsDouble)")
        
        let spentThisMonthAsDouble: Double = spentThisMonth.doubleValue
        print("debug for Calculate savings: spentThisMonth = \(spentThisMonthAsDouble)")
        
        let dailyLimit = (monthlyBudgetAsDouble - (savingsGoal!.amount.doubleValue))/Double(numbersOfDaysInCurrentMonth)
        print("debug for Calculate savings: dailyLimit = \(dailyLimit)")
        
        let savedThisMonthAsDouble = monthlyBudgetAsDouble - (spentThisMonthAsDouble + (Double(numberOfDaysUntilEndOfMonth-1))*dailyLimit)
        print("debug for Calculate savings: savedThisMonth = \(savedThisMonthAsDouble)")
        
        
        return NSDecimalNumber(double: savedThisMonthAsDouble)
        
    }
    
    func drawSpendingsOverviewChart() {
        
        
        //Get last 7 days
        
        
        
        //Calculating spendings of the last 7 days
        
        
        let today = Double(valueForLabelSpentToday)
        
        let todayMinus1 = Double(spentInDateInterval(NSDate().dateOfDaysBeforeOrAfter(-1).startOfDay, endDate: NSDate().dateOfDaysBeforeOrAfter(-1).endOfDay!))
        
        let todayMinus2 = Double(spentInDateInterval(NSDate().dateOfDaysBeforeOrAfter(-2).startOfDay, endDate: NSDate().dateOfDaysBeforeOrAfter(-2).endOfDay!))
        
        let todayMinus3 = Double(spentInDateInterval(NSDate().dateOfDaysBeforeOrAfter(-3).startOfDay, endDate: NSDate().dateOfDaysBeforeOrAfter(-3).endOfDay!))
        
        let todayMinus4 = Double(spentInDateInterval(NSDate().dateOfDaysBeforeOrAfter(-4).startOfDay, endDate: NSDate().dateOfDaysBeforeOrAfter(-4).endOfDay!))
        
        let todayMinus5 = Double(spentInDateInterval(NSDate().dateOfDaysBeforeOrAfter(-5).startOfDay, endDate: NSDate().dateOfDaysBeforeOrAfter(-5).endOfDay!))
        
        let todayMinus6 = Double(spentInDateInterval(NSDate().dateOfDaysBeforeOrAfter(-6).startOfDay, endDate: NSDate().dateOfDaysBeforeOrAfter(-6).endOfDay!))
        
        daysForBarChart=[]
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE"
        var x = 0
        for i in 0...6 {
            let dayName = dateFormatter.stringFromDate(NSDate().dateOfDaysBeforeOrAfter(x))
            daysForBarChart.append(dayName)
            x-=1
        }
        
        
        
        
        setChart(daysForBarChart.reverse(), values: [todayMinus6,todayMinus5,todayMinus4,todayMinus3,todayMinus2,todayMinus1,today])
        
        
    }
    
    
        
    
    func setChart(dataPoints: [String], values: [Double]) {
        barChartView.noDataText = "You need to provide data for the chart."
        
        
        let numberOfDaysUntilEndOfMonth = NSDate().daysBetweenDates(NSDate(), endDate: NSDate().endOfMonth())
        let spentThisMonth = spentInDateInterval(NSDate().startOfMonth(), endDate: NSDate())
        

        
        let monthlyBudgetAsDouble: Double = monthlyBudget.amount.doubleValue
        let spentThisMonthAsDouble: Double = spentThisMonth.doubleValue
        let dailyLimit = (monthlyBudgetAsDouble - savingsGoal!.amount.doubleValue)/Double(numbersOfDaysInCurrentMonth)
        
        
        print("the other dailyLimit: \(dailyLimit)")
        
        
        //Some Chart UI changes
        barChartView.leftAxis.drawGridLinesEnabled = false
        barChartView.rightAxis.drawGridLinesEnabled = false
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.drawBordersEnabled = false
        barChartView.leftAxis.drawZeroLineEnabled = false
        barChartView.rightAxis.drawLabelsEnabled = false
        barChartView.borderColor = UIColor.clearColor()
        barChartView.leftAxis.drawAxisLineEnabled = false
        barChartView.rightAxis.drawAxisLineEnabled = false
        barChartView.xAxis.drawAxisLineEnabled = false
        barChartView.drawValueAboveBarEnabled = false
        barChartView.leftAxis.drawLabelsEnabled = false
        barChartView.descriptionText = ""
        barChartView.legend.enabled = false
        
        
        barChartView.scaleXEnabled = false
        barChartView.scaleYEnabled = false
        var dataEntries: [BarChartDataEntry] = []
        var chartColorSet : [UIColor] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
            if (Double(values[i]) < dailyLimit) {
                chartColorSet.append(blue)
            } else {
                chartColorSet.append(pink)
            }
        }
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "money spent")
        chartDataSet.barSpace = 0.8
        
        chartDataSet.drawValuesEnabled = false
        let chartData = BarChartData(xVals: dataPoints, dataSet: chartDataSet)
        
        chartDataSet.colors = chartColorSet
        barChartView.animate(xAxisDuration: 0, yAxisDuration: 1.0)
        
        
        
        
        ll.limit = dailyLimit
        ll.labelPosition = .LeftTop
        ll.drawLabelEnabled = false
        ll.lineColor = UIDesign().red
        ll.lineWidth = 0.5
        barChartView.data = chartData
        
    }
    
    
      
   
    
    
    
}

// Lets write an extension for the Dates stuff
extension NSDate {
    
    func startOfMonth() -> NSDate {
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month], fromDate: date)
        let startOfMonth = calendar.dateFromComponents(components)!
        
        return startOfMonth
    }
    func endOfMonth() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let comps2 = NSDateComponents()
        comps2.month = 1
        comps2.day = -1
        let endOfMonth = calendar.dateByAddingComponents(comps2, toDate: NSDate().startOfMonth(), options: [])!
        
        return endOfMonth
    }
    func dateOfDaysBeforeOrAfter(nmberOfDaysBeforeOrAfter: Int) -> NSDate {
        let newDateComponents = NSDateComponents()
        newDateComponents.day = nmberOfDaysBeforeOrAfter
        let dateOfDaysBeforeOrAfter = NSCalendar.currentCalendar().dateByAddingComponents(newDateComponents, toDate: NSDate(), options: NSCalendarOptions.init(rawValue: 0))!
        
        return dateOfDaysBeforeOrAfter
    }
    func daysBetweenDates(startDate: NSDate, endDate: NSDate) -> Int
    {
        let calendar = NSCalendar.currentCalendar()
        
        let components = calendar.components([.Day], fromDate: startDate, toDate: endDate, options: [])
        
        return components.day
    }
    
    
    
    var startOfDay: NSDate {
        return NSCalendar.currentCalendar().startOfDayForDate(self)
    }
    
    var endOfDay: NSDate? {
        let components = NSDateComponents()
        components.day = 1
        components.second = -1
        return NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: startOfDay, options: NSCalendarOptions())
    }
    
    var startOfWeek: NSDate {
        let calendar = NSCalendar.currentCalendar()
        let currentDateComponents = calendar.components([.YearForWeekOfYear, .WeekOfYear ], fromDate: NSDate())
        return calendar.dateFromComponents(currentDateComponents)!
        
    }
}
