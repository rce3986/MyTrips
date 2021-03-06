//
//  TripData.swift
//  MyTrips
//
//  Created by Ryan Elliott on 8/10/21.
//

import Foundation

class TripData: Codable {
    
    
    var days: [Day] = []
    var tripCount: Int = 0
    
    /* * Helpers * */
    
    /*
     * Returs false if row or section are out of range, true otherwise
     */
    func remove(row: Int, section: Int) -> Bool {
        
        // If given section is out of range
        if section < 0 || self.days.count <= section {
            print("Couldn't remove: section \(section) out of range for count \(self.days.count)")
            return false
        }
        
        let day = self.days[section]
        
        // If given row is out of range for given section
        if !day.remove(row: row) {
            return false
        }
        
        tripCount -= 1
        
        
        // If a day is empty, remove it from days
        if day.trips.count == 0 {
            self.days.remove(at: section)
        }
        
        return true
    }
    
    /*
     * Returns the index of the given date
     * If there are no trips, nil is returned
     */
    func getIndex(_ date: Date) -> Int? {
        if self.days.count == 0 {
            return nil
        }
        return binarySearch(arr: self.days, item: Day(date))
    
    }
    
    /*
     * Adds a trip to the data structure
     * Similar to add function except instead of adding to the end it can be inserted anywhere
     * Returns true if a new day was added, false otherwise
     */
    func insert(_ trip: Trip) {
        tripCount += 1
        let n = self.days.count
        
        let day = Day(trip)
        let i = binarySearch(arr: self.days, item: day)
        if 0 < n && i < n && day == self.days[i] {  // Day already exists
            self.days[i].insert(trip)
        } else {                                    // Add a new day
            self.days.insert(day, at: i)
        }
       
       
    }
    
    /*
     * Adds a trip to the data structure
     * Returns true if a new day was added, false otherwise
     */
    func add(_ trip: Trip) {
        let day = Day(trip)
        guard let last = self.days.last, last == day else {
            // Either no trips exist or day is greater than every existing day
            self.days.append(day)
            return
        }
        last.add(trip)
        
    }
    
    
    /*
     * Returns the row and section for a given date
     * If the date doesn't exist, the next date greater is returned
     */
    func rowAndSectionFor(_ date: Date) -> (Int, Int) {
        let day = Day(date)
        let n = self.days.count
        let i = binarySearch(arr: self.days, item: day)
        
        // Date is greater than all existing dates
        if i == n {
            return (self.days[i-1].trips.count-1, i-1)
        }
        
        return (day == self.days[i] ? self.days[i].rowFor(date) : 0, i)
        
        
        
        
    }
    
    /*
     * Returns nil if index given is out of range
     */
    func get(section index: Int) -> [Trip]? {
        if index < 0 || index >= self.days.count {
            return nil
        }
        return self.days[index].trips
    }
    
    // Check if number of trips is 0 before calling
    func get(row: Int, section: Int) -> Trip? {
        guard let trips = get(section: section) else {
            return nil
        }
        return trips[row]
        
    }
    
}

extension TripData: Iterable {
    func makeIterator(start: Date, end: Date) -> TripDataIterator {
        TripDataIterator(self, start: start, end: end)
    }
}
