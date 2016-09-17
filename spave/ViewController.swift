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
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var seperatorLine: CustomSeperatorLine!
    @IBOutlet weak var viewLeftNumber: UIView!
    @IBOutlet weak var buttonForSpendings: UIBarButtonItem!
    let defaults = UserDefaults.standard
    let blue = UIColor(red: 60/255, green: 176/255, blue: 226/255, alpha: 1.0)
    let pink = UIColor(red: 226/255, green: 60/255, blue: 105/255, alpha: 1.0)
    let darkBlue = UIColor(red: 41/255, green: 52/255, blue: 72/255, alpha: 1.0)
    let ll: ChartLimitLine = ChartLimitLine()
    
    var numbersOfDaysInCurrentMonth: Int {
        //Numbers of days of current month
        let calendar = Calendar.current
        return (calendar as NSCalendar).component([.day], from: Date().endOfMonth())
    }
    
    
    
    var totalCostOfTheDay: Int = 0
    var dailyLimit: Int = 6
    var daysForBarChart: [String] = []
    var monthlyBudget: Money!
    var formatter: NumberFormatter = NumberFormatter()
    
    
    
    var valueForLabelSpentToday: NSDecimalNumber = 0 {
        didSet {
            let money = Money(amount: valueForLabelSpentToday, currencyIsoString: defaults.object(forKey: "usersDefaultCurrency") as! String)
            labelForSpentToday.text = formatter.string(from: money.amount)
        }
    }
    
    var valueForLabelSpentThisWeek: NSDecimalNumber = 0 {
        didSet {
            let money = Money(amount: valueForLabelSpentThisWeek, currencyIsoString: defaults.object(forKey: "usersDefaultCurrency") as! String)
            labelForSpentThisWeek.text = formatter.string(from: money.amount)
        }
    }
    
    var savedThisMonth: NSDecimalNumber = 0 {
        didSet {
            let money = Money(amount: savedThisMonth, currencyIsoString: defaults.object(forKey: "usersDefaultCurrency") as! String)
            let currencySymbol = Money(amount: 1, currencyIsoString: defaults.object(forKey: "usersDefaultCurrency") as! String).currency!.getCurrencySymbol()
            labelForSavingsGoal.text = formatter.string(from: savedThisMonth)
            customProgressBar.savingsGoal = Int(defaults.double(forKey: "savingsGoal"))
            customProgressBar.counter = savedThisMonth.doubleValue
        }
    }
    
    var savingsGoal: Money?
    
    // MARK:  - Properties
    var fetchedResultsController : NSFetchedResultsController<Expense>?
    
    

    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        //Load user defaults
        savingsGoal = Money(amount: NSDecimalNumber(value: defaults.double(forKey: "savingsGoal") as Double),
                            currencyIsoString: defaults.object(forKey: "usersDefaultCurrency") as! String)
        
        
        monthlyBudget = Money(amount: NSDecimalNumber(value: defaults.double(forKey: "monthlyBudget") as Double),
                              currencyIsoString: defaults.object(forKey: "usersDefaultCurrency") as! String)
        
        print(monthlyBudget)

        
        
        //ll = ChartLimitLine(limit: dailyLimit, label: "")
        
        barChartView.leftAxis.addLimitLine(ll)

        
        customProgressBar.savingsGoal = savingsGoal!.amount.intValue
        
        //Some UI changes
        customProgressBar.backgroundColor = UIColor.clear
        //let font = UIFont(name: ".SFUIText-Regular", size: 14)!
        //buttonForSpendings.setTitleTextAttributes([NSFontAttributeName: ], for: UIControlState())
        
        
        
        
        
        
        //UIBarButtonItem.appearance().setBackButtonBackgroundImage(backImg, forState: .Normal, barMetrics: .Default)
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "BackIcon")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "BackIcon")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.tintColor = UIDesign().lightGrey
        
        let navBar = navigationController!.navigationBar
        
        
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        navBar.isTranslucent = true
        
        
        
        //navBarColor.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        
        // Get the stack
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        
        //Create fetch request to load the saved expenses
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Expense")
        fr.sortDescriptors = [NSSortDescriptor(key: "value", ascending: true),
                              NSSortDescriptor(key: "date", ascending: false)]
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr as! NSFetchRequest<Expense>,
                                                              managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        
        
        barChartView.noDataTextDescription = "No data yet. Start tracking by adding your expenses"
        
       
        
        //Check if the user opens the app for the first time. If so, show onboarding
        
        if defaults.bool(forKey: "UserHasSeenOnboarding") {
            //Do nothing
        } else {
            let onboardingController = self.storyboard?.instantiateViewController(withIdentifier: "Onboarding") as! OnboardingPageViewController
            self.present(onboardingController, animated: true, completion: nil)
        }

        
        
        
        //Check if database seems to by empty, then fire up a modal to ask the user to enter the spent money this month to populate the database with it
        let spendingsEver = spentInDateInterval(Date().dateOfDaysBeforeOrAfter(-20000).startOfDay, endDate: Date().dateOfDaysBeforeOrAfter(0).endOfDay!)
        let numberOfDaysSinceStartOfMonth = Date().daysBetweenDates(Date().startOfMonth(), endDate: Date())
        
        print("Number of days since start of month: \(numberOfDaysSinceStartOfMonth)")
        
        if (spendingsEver == 0) && (numberOfDaysSinceStartOfMonth != 0) {
            
            
            
            let calendar = Calendar.current
            let components = (calendar as NSCalendar).components([.day , .month , .year], from: Date())
            
            
            let month = components.month
            let monthName = DateFormatter().monthSymbols[month! - 1]
            
            let alert = UIAlertController(title: "Howdy", message: "Looks like you are using the app the very first time or dropped all your data. Please enter the amount of money you've already spent this month (\(monthName)). If you don't know, just estimate and trust your gut feeling.", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Save", style: UIAlertActionStyle.default, handler: {(UIAlertAction) -> Void in
                
                //Number of days since begin of month
                
                var x = 0
                let currency = self.defaults.object(forKey: "usersDefaultCurrency") as! String
                //spendings until now, estimated by the user
                if let spendingsUntilNow = Int(alert.textFields![0].text!) {
                    
                    //Fill database with estimated spendings
                    while x < numberOfDaysSinceStartOfMonth {
                        var expenseToTrack = Expense(value: NSDecimalNumber(value: spendingsUntilNow/numberOfDaysSinceStartOfMonth as Int), date: Date().dateOfDaysBeforeOrAfter(-1*numberOfDaysSinceStartOfMonth+x), context: self.self.fetchedResultsController!.managedObjectContext)
                        expenseToTrack.currency = currency
                        x+=1
                    }
                }
                self.self.drawSpendingsOverviewChart()
                self.self.viewDidAppear(false)
                
            }))
            
            alert.addTextField(configurationHandler: {(UITextField) -> Void in
                let textField = UITextField
                
                textField.text="0"
                
            })
            
            self.present(alert, animated: true, completion: nil)
        }
        
        
        
         updateUI()
    
    }
    

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        

        formatter.numberStyle = .currencyAccounting
        formatter.maximumFractionDigits = 0
        
        NotificationCenter.default.addObserver(self, selector:#selector(ViewController.updateUI), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.updateUI), name:NSNotification.Name(rawValue: "AddExpenseModalDismissed"), object: nil)
        
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
            stackView.axis = .horizontal
        } else {
            stackView.axis = .vertical
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    
    
    func updateUI() {
        
        let currency = Money(amount: 1, currencyIsoString: defaults.object(forKey: "usersDefaultCurrency") as! String).currency!
        
        let formatter = NumberFormatter()
        formatter.currencyCode = currency.rawValue
        formatter.numberStyle = .currencyAccounting
        formatter.roundingMode = .halfEven
        formatter.maximumFractionDigits = 0
        

        
        valueForLabelSpentToday = spentInDateInterval(Date().startOfDay, endDate: Date().endOfDay!)
        valueForLabelSpentThisWeek = spentInDateInterval(Date().startOfWeek, endDate: Date().endOfDay!)
        savedThisMonth = calculateSavingsThisMonth()
        customProgressBar.savingsGoal = Int(defaults.double(forKey: "savingsGoal"))
        
        
        // Update labels
        labelForSpentToday.text = formatter.string(from: valueForLabelSpentToday)
        labelForSpentThisWeek.text = formatter.string(from: valueForLabelSpentThisWeek)
        labelForSavingsGoal.text = formatter.string(from: savedThisMonth)
        customProgressBar.counter = savedThisMonth.doubleValue
        
        // Update chart
        drawSpendingsOverviewChart()
    }
    
    // func spentThisWeek()
    // Query - Get all tracked expenses for the week - predicate: %@ <= date AND date <= %@
    // Sum the expenses
    // Create Fetch Request
    // return what we spent today
    func spentInDateInterval(_ startDate: Date, endDate: Date) -> NSDecimalNumber {
        
        var spent: NSDecimalNumber = 0
        let expensesFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Expense")
        expensesFetch.predicate = NSPredicate(format: "%@ <= date AND date <= %@", startDate as CVarArg, endDate as CVarArg)
        
        do {
            let fetchedExpenses = try fetchedResultsController!.managedObjectContext.fetch(expensesFetch) as! [Expense]
            for expense in fetchedExpenses {
                spent = spent.adding(expense.value!)
            }
        } catch {
            fatalError("Failed to fetch expenses: \(error)")
        }
        
        return spent
    }
    
    
    func calculateSavingsThisMonth() -> NSDecimalNumber {
        
        //Algorithm: monthlyBudget - spentThisMonth + (numberOfDaysUntilEndOfMonth*dailyBudget)
        
        //numberOfDaysUntilEndOfMonth - get the number of days until end of month
        
        
        let numberOfDaysUntilEndOfMonth = Date().daysBetweenDates(Date(), endDate: Date().endOfMonth())
        print("debug for Calculate savings: numberOfDaysUntilEndOfMonth = \(numberOfDaysUntilEndOfMonth)")
        let spentThisMonth = spentInDateInterval(Date().startOfMonth(), endDate: Date())
        
        
        
        let monthlyBudgetAsDouble: Double = defaults.double(forKey: "monthlyBudget")
        print("debug for Calculate savings: monthlyBudget = \(monthlyBudgetAsDouble)")
        
        let spentThisMonthAsDouble: Double = spentThisMonth.doubleValue
        print("debug for Calculate savings: spentThisMonth = \(spentThisMonthAsDouble)")
        
        let dailyLimit = (monthlyBudgetAsDouble - (savingsGoal!.amount.doubleValue))/Double(numbersOfDaysInCurrentMonth)
        print("debug for Calculate savings: dailyLimit = \(dailyLimit)")
        
        let savedThisMonthAsDouble = monthlyBudgetAsDouble - (spentThisMonthAsDouble + (Double(numberOfDaysUntilEndOfMonth-1))*dailyLimit)
        print("debug for Calculate savings: savedThisMonth = \(savedThisMonthAsDouble)")
        
        return NSDecimalNumber(value: savedThisMonthAsDouble as Double)
        
    }
    
    func drawSpendingsOverviewChart() {
        
        
        //Get last 7 days
        
        
        
        //Calculating spendings of the last 7 days
        
        
        let today = Double(valueForLabelSpentToday)
        
        let todayMinus1 = Double(spentInDateInterval(Date().dateOfDaysBeforeOrAfter(-1).startOfDay, endDate: Date().dateOfDaysBeforeOrAfter(-1).endOfDay!))
        
        let todayMinus2 = Double(spentInDateInterval(Date().dateOfDaysBeforeOrAfter(-2).startOfDay, endDate: Date().dateOfDaysBeforeOrAfter(-2).endOfDay!))
        
        let todayMinus3 = Double(spentInDateInterval(Date().dateOfDaysBeforeOrAfter(-3).startOfDay, endDate: Date().dateOfDaysBeforeOrAfter(-3).endOfDay!))
        
        let todayMinus4 = Double(spentInDateInterval(Date().dateOfDaysBeforeOrAfter(-4).startOfDay, endDate: Date().dateOfDaysBeforeOrAfter(-4).endOfDay!))
        
        let todayMinus5 = Double(spentInDateInterval(Date().dateOfDaysBeforeOrAfter(-5).startOfDay, endDate: Date().dateOfDaysBeforeOrAfter(-5).endOfDay!))
        
        let todayMinus6 = Double(spentInDateInterval(Date().dateOfDaysBeforeOrAfter(-6).startOfDay, endDate: Date().dateOfDaysBeforeOrAfter(-6).endOfDay!))
        
        daysForBarChart=[]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        var x = 0
        for i in 0...6 {
            let dayName = dateFormatter.string(from: Date().dateOfDaysBeforeOrAfter(x))
            daysForBarChart.append(dayName)
            x-=1
        }
        
        
        
        
        setChart(daysForBarChart.reversed(), values: [todayMinus6,todayMinus5,todayMinus4,todayMinus3,todayMinus2,todayMinus1,today])
        
        
    }
    
    
        
    
    func setChart(_ dataPoints: [String], values: [Double]) {
        barChartView.noDataText = "You need to provide data for the chart."
        
        
        let numberOfDaysUntilEndOfMonth = Date().daysBetweenDates(Date(), endDate: Date().endOfMonth())
        let spentThisMonth = spentInDateInterval(Date().startOfMonth(), endDate: Date())
        

        
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
        barChartView.borderColor = UIColor.clear
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
            let dataEntry = BarChartDataEntry(x: Double(i), yValues: [values[i]])
            //let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
            if (Double(values[i]) < dailyLimit) {
                chartColorSet.append(blue)
            } else {
                chartColorSet.append(pink)
            }
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "money spent")
        
        //chartDataSet.barSpace = 0.8
        
        chartDataSet.drawValuesEnabled = false
        let chartData = BarChartData(dataSets: [chartDataSet])
        //let chartData = BarChartData(xVals: dataPoints, dataSet: chartDataSet)
        
        chartDataSet.colors = chartColorSet
        barChartView.animate(xAxisDuration: 0, yAxisDuration: 1.0)
        
        
        
        
        ll.limit = dailyLimit
        ll.labelPosition = .leftTop
        ll.drawLabelEnabled = false
        ll.lineColor = UIDesign().red
        ll.lineWidth = 0.5
        
        barChartView.data = chartData
        
    }
    
    
      
   
    
    
    
}

// Lets write an extension for the Dates stuff
extension Date {
    
    func startOfMonth() -> Date {
        let date = Date()
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.year, .month], from: date)
        let startOfMonth = calendar.date(from: components)!
        
        return startOfMonth
    }
    func endOfMonth() -> Date {
        let calendar = Calendar.current
        var comps2 = DateComponents()
        comps2.month = 1
        comps2.day = -1
        let endOfMonth = (calendar as NSCalendar).date(byAdding: comps2, to: Date().startOfMonth(), options: [])!
        
        return endOfMonth
    }
    func dateOfDaysBeforeOrAfter(_ nmberOfDaysBeforeOrAfter: Int) -> Date {
        var newDateComponents = DateComponents()
        newDateComponents.day = nmberOfDaysBeforeOrAfter
        let dateOfDaysBeforeOrAfter = (Calendar.current as NSCalendar).date(byAdding: newDateComponents, to: Date(), options: NSCalendar.Options.init(rawValue: 0))!
        
        return dateOfDaysBeforeOrAfter
    }
    func daysBetweenDates(_ startDate: Date, endDate: Date) -> Int
    {
        let calendar = Calendar.current
        
        let components = (calendar as NSCalendar).components([.day], from: startDate, to: endDate, options: [])
        
        return components.day!
    }
    
    
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date? {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return (Calendar.current as NSCalendar).date(byAdding: components, to: startOfDay, options: NSCalendar.Options())
    }
    
    var startOfWeek: Date {
        let calendar = Calendar.current
        let currentDateComponents = (calendar as NSCalendar).components([.yearForWeekOfYear, .weekOfYear ], from: Date())
        return calendar.date(from: currentDateComponents)!
        
    }
}
