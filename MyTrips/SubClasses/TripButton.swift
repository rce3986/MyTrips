//
//  TripButton.swift
//  MyTrips
//
//  Created by Ryan Elliott on 7/24/21.
//

import UIKit

class TripButton: UIButton {

    var trip: Bool = false
    var locationIsOn: Bool = false
    
    /* * Initialization * */
    /*
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //self.bringSubviewToFront(self)
        self.layer.cornerRadius = 12.5
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    */
    func configure() {
        self.layer.cornerRadius = 12.5
    }
    
    /* * Helpers * */
    
    
    
    func toggle() {
        if trip {   // Stop the trip
            self.setTitle("Start New Trip", for: .normal)
            self.backgroundColor = UIColor.systemBlue
        } else {    // Start the trip
            self.setTitle("End Trip", for: .normal)
            self.backgroundColor = UIColor.systemRed
        }
        trip = !trip
    }
    
}
