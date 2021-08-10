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
    @IBOutlet weak var fileTextBox: UITextField!
    @IBOutlet weak var fileLabel: UILabel!
    
    var tripData: TripData = TripData()
    var dateFormatter: DateFormatter = DateFormatter()
    var timeFormatter: DateFormatter = DateFormatter()
    
    func reloadData() {
        // DatePickers
        let today = Date()
        let min = self.tripData.get(row: 0, section: 0)?.getStartDate() ?? today
        
        self.fromDatePicker.maximumDate = today
        self.toDatePicker.maximumDate = today
        self.fromDatePicker.minimumDate = min
        self.toDatePicker.minimumDate = min
        self.fromDatePicker.setDate(min, animated: false)
        
        // Labels
        self.clearLabels()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let parent = self.parent as! TabBarController
        
        self.tripData = parent.data.tripData
        self.dateFormatter.dateStyle = .short
        self.dateFormatter.locale = Locale(identifier: "en_US")
        self.timeFormatter = parent.timeFormatter
        
        // TextBox
        self.fileTextBox.autocorrectionType = .no
        self.fileTextBox.returnKeyType = .done
        
        // Reload
        self.reloadData()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func dateValueDoneEditing(_ sender: UIDatePicker) {
  
        // If dates aren't messed up then return
        if self.fromDatePicker.date < self.toDatePicker.date {
            return
        }
        
        // Set dates to be the same as sender
        if sender == self.fromDatePicker {
            self.toDatePicker.date = self.fromDatePicker.date
        } else {
            self.fromDatePicker.date = self.toDatePicker.date
        }
        
        
        
    }
    
    func clearLabels() {
        self.fileLabel.text = ""
    }
    

    @IBAction func exportButtonTapped(_ sender: UIButton) {
        self.clearLabels()
        
        // Trim whitespace
        let text = self.fileTextBox.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If no text is entered
        if text == "" {
            self.fileLabel.text = "You need to enter a filename"
            return
        }
        
        self.clearLabels()
        
        // Get rid of keyboard
        self.fileTextBox.resignFirstResponder()
        
        // Create file
        let items: [Any] = [createCSV(filename: text)]
        
        
        // Present view that allows user to choose where to send the file
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        ac.excludedActivityTypes = [.addToReadingList,.assignToContact,.saveToCameraRoll,.postToFacebook,.postToWeibo,.postToVimeo,.postToFlickr,.postToTwitter,.postToTencentWeibo]
        
        present(ac, animated: true)
    }
    
    func createCSV(filename: String) -> URL {
        
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(filename).csv")!
        var csvText = "Date,Start Time,End Time,Distance\n"
        
        
        
        let iterator = self.tripData.makeIterator(start: self.fromDatePicker.date, end: self.toDatePicker.date)
        
        while let next = iterator.next() {
            let date = self.dateFormatter.string(from: next.getStartDate())
            let startTime = self.timeFormatter.string(from: next.getStartDate())
            let endTime = self.timeFormatter.string(from: next.getEndDate())
            let distance = next.distance
            let newline = "\(date),\(startTime),\(endTime),\(distance)\n"
            csvText.append(newline)
        }
        
        
        do {
            try csvText.write(to: path, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
        
        return path
 
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func doneWithKeyboard(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
}
