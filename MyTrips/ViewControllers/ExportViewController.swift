//
//  ExportViewController.swift
//  MyTrips
//
//  Created by Ryan Elliott on 8/2/21.
//

import UIKit

class ExportViewController: UIViewController {

    
    
    @IBOutlet weak var fromDatePicker: UIDatePicker!
    @IBOutlet weak var toDatePicker: UIDatePicker!
    
    var components: Components = Components()
    var dateFormatter: DateFormatter = DateFormatter()
    var timeFormatter: DateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let parent = self.parent as! TabBarController
        
        self.components = parent.data.components
        self.dateFormatter = parent.dateFormatter
        self.timeFormatter = parent.timeFormatter
        
        let today = Date()
        var min = today
        self.fromDatePicker.maximumDate = today
        self.toDatePicker.maximumDate = today
        if self.components.tripCount > 0 {
            min = components.get(row: 0, section: 0).startDate
            
        }
        self.fromDatePicker.minimumDate = min
        self.toDatePicker.minimumDate = min
        self.fromDatePicker.setDate(min, animated: false)
        
        
        
        // Do any additional setup after loading the view.
    }
    

    @IBAction func exportButtonTapped(_ sender: UIButton) {
        
        // set items to the file
        
        let items: [Any] = []
        
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        ac.excludedActivityTypes = [.addToReadingList,.assignToContact,.saveToCameraRoll,.postToFacebook,.postToWeibo,.postToVimeo,.postToFlickr,.postToTwitter,.postToTencentWeibo]
        
        present(ac, animated: true)
    }
    
    func createCSV() {
        
        let filename = "trips.csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)
        var csvText = "Date,Start Time,End Time,Distance\n"
        
        
        
        let iterator = self.components.makeIterator(start: self.fromDatePicker.date, end: self.toDatePicker.date)
        
        while let next = iterator.next() {
            let date = self.dateFormatter.string(from: next.startDate)
            let startTime = self.timeFormatter.string(from: next.startDate)
            let endTime = self.timeFormatter.string(from: next.endDate)
            let distance = next.distance
            let newline = "\(date),\(startTime),\(endTime),\(distance)\n"
            csvText.append(newline)
        }
        
        do {
            try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
