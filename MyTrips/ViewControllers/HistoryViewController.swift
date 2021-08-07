//
//  HistoryViewController.swift
//  MyTrips
//
//  Created by Ryan Elliott on 7/24/21.
//

import UIKit

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var calendarView: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!
    

    var components: Components = Components() // Helps tableView react to calendar selection
    var dateFormatter: DateFormatter = DateFormatter()
    var timeFormatter: DateFormatter = DateFormatter()
    
    let calendar: Calendar = Calendar(identifier: .gregorian)
    let dateComponents: Set<Calendar.Component> = [.day, .month, .year]
    let cellReuseIdentifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let parent = self.parent as! TabBarController
        
        self.components = parent.data.components
        self.dateFormatter = parent.dateFormatter
        self.timeFormatter = parent.timeFormatter
        
        // DateFormatters
        self.dateFormatter.dateStyle = .medium
        self.dateFormatter.locale = Locale(identifier: "en_US")
        self.timeFormatter.setLocalizedDateFormatFromTemplate("HH:mm")
        self.timeFormatter.locale = Locale(identifier: "en_US")

        /*
        // FSCalendar
        self.calendarView.calendarHeaderView.scrollDirection = .vertical
        self.calendarView.register(FSCalendarCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        self.calendarView.delegate = self
        self.calendarView.dataSource = self
        

        
        
        
        
        
        // Header Buttons
        self.calendarView.bringSubviewToFront(self.todayButton)
        self.calendarView.bringSubviewToFront(self.insertButton)
        */
        
        // CalendarView
        self.calendarView.maximumDate = self.calendar.date(byAdding: .day, value: 1, to: Date())
        
        
        // TableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.allowsSelection = false
        
    }
    
    /* * Actions * */
    
    @IBAction func insertButtonTapped(_ sender: UIButton) {
        
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "Insert") as! InsertViewController
        vc.delegate = self.parent as? TabBarController
        vc.title = "Create Trip"
        let navController = UINavigationController(rootViewController: vc)
        self.present(navController, animated: true, completion: nil)
    }
    
    @IBAction func todayButtonTapped(_ sender: UIButton) {
        // get "today" date
        let today = Date()
        
        // get selected date
        let pickerDate = self.calendarView.date
        
        // are the dates the same day?
        let todayIsSelected = Calendar.current.isDate(today, inSameDayAs:pickerDate)

        if todayIsSelected {
            // picker has today selected, but may have scrolled months...

            // should never fail, but this unwraps the optional
            guard let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: today) else {
                return
            }

            // animate to "tomorrow"
            self.calendarView.setDate(nextDay, animated: true)

            // async call to animate to "today" - delay for 0.1 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.calendarView.setDate(today, animated: true)
            })
        } else {
            // picker has a different date selected
            //  so just animate to "today"
            self.calendarView.setDate(today, animated: true)
        }
    }
    
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        self.scrollToDate(self.calendarView.date)
    }
    
    
    /* * Helpers * */
    
    func scrollToDate(_ date: Date) {
        if self.components.sectionCount == 0 {
            return
        }
        let (_, section) = self.components.rowAndSectionFor(date)
        let indexPath = IndexPath(row: 0, section: min(section, self.components.sectionCount-1))
        
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    /*
    /* * FSCalendar * */
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        calendar.today!
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.scrollToDate(date)
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let (_, section) = self.components.rowAndSectionFor(date)
        guard let trips = self.components.get(section: section), MyTrips.components(trips[0].startDate) == MyTrips.components(date) else {
            return 0
        }
        return trips.count
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
            
        let defaultColor = appearance.titleDefaultColor
        
        if #available(iOS 12.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                return .white
            } else {
                return defaultColor
            }
        } else {
            return defaultColor
        }
            
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        self.calendarView?.reloadData()
    }
    */
    /* * UITableView * */
    
    func numberOfSections(in tableView: UITableView) -> Int {
        self.components.sectionCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.components.get(section: section)?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)! as! TableViewCell
        
        let trip = self.components.get(row: indexPath.row, section: indexPath.section)!
        let startTime = self.timeFormatter.string(from: trip.startDate)
        let endTime = self.timeFormatter.string(from: trip.endDate)
        
        cell.textLabel?.text = "\(startTime) - \(endTime)"
        cell.mileLabel.text = "\(trip.distance) mi"
                
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        self.dateFormatter.string(from: self.components.get(row: 0, section: section)!.startDate)
    }
    


}
