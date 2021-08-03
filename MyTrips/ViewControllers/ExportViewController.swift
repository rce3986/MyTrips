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
    
    //let calendar: Calendar = Calendar(identifier: .gregorian)
    var components: Components = Components()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.components = (self.parent as! TabBarController).data.components
        
        let today = Date()
        self.fromDatePicker.maximumDate = today
        self.toDatePicker.maximumDate = today
        self.fromDatePicker.minimumDate = today
        self.toDatePicker.minimumDate = today
        if self.components.tripCount > 0 {
            let min = components.get(row: 0, section: 0).startDate
            self.fromDatePicker.minimumDate = min
            self.toDatePicker.minimumDate = min
        }
        
        
        
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