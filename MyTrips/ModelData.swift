//
//  ModelData.swift
//  MyTrips
//
//  Created by Ryan Elliott on 7/24/21.
//

import Foundation
import CoreLocation
import MapKit

protocol Iterable {
    func makeIterator(start: Date, end: Date) -> ComponentsIterator
}

class Components: Codable, Iterable {
    
    
    var years: [Year] = []
    var sectionCount: Int = 0
    var tripCount: Int = 0
    
    
    
    func makeIterator(start: Date, end: Date) -> ComponentsIterator {
        ComponentsIterator(self, start: start, end: end)
    }
    
    // Returns the index of the given year. If the year doesn't exist, returns the index of the next highest year
    func getIndex(_ date: DateComponents) -> (Int, Int, Int)? {
        
        // Param year is less than any year in components
        if self.years.count > 0 && self.years[0].year > date.year! {
            return (0, 0, 0)
        }
        
        var i = 0
        while i < self.years.count && self.years[i].year < date.year! {
            i += 1
        }
        if i == self.years.count {
            return nil
        }
        if let (month, day) = self.years[i].getIndex(date) {
            return (i, month, day)
        }
        i += 1
        if i == self.years.count {
            return nil
        }
        return (i, 0, 0)
    }
    
    /*
     * Adds a trip to the data structure
     * Similar to add function except instead of adding to the end it can be inserted anywhere
     * Returns true if a new day was added, false otherwise
     */
    func insert(_ trip: Trip) {
        
        self.tripCount += 1
        let components = components(trip.startDate)
        let year = components.year!
        
        
        var i = 0
        while i < self.years.count && year < self.years[i].year {
            i += 1
        }
        
        if i < self.years.count && self.years[i].year == year {
            // Add to existing year
            if !self.years[i].insert(trip, components: components) {
                return
            }
        } else {
            i = i == 0 || (i == self.years.count && self.years[i-1].year < year) ? i : i-1
            
            // Need to add a new year, month, and day (section)
            self.years.insert(Year(year: year), at: i)
            self.years[i].add(trip, components: components)
        }
        
        self.sectionCount += 1
       
    }
    
    /*
     * Adds a trip to the data structure
     * Returns true if a new day was added, false otherwise
     */
    func add(_ trip: Trip) {
        
        self.tripCount += 1
        let components = components(trip.startDate)
        let year = components.year!
        
        // Determine if a there needs to be a new section
        if let last = self.years.last, last.year == year {
            // Add to current year
            if !last.add(trip, components: components) {
                return
            }
        } else {
            // Need to add a new year, month, and day (section)
            self.years.append(Year(year: year))
            self.years.last!.add(trip, components: components)
        }
        
        // New section was created
        self.sectionCount += 1
        
    }
    
    
    
    func rowAndSectionFor(_ date: Date) -> (Int, Int) {
        let components = components(date)
        let year = components.year!
        var i = 0
        var sections = 0
        while i < self.years.count && self.years[i].year < year {
            sections += self.years[i].sectionCount
            i += 1
        }
        
        // Greater than existing years
        if i == self.years.count {
            return (0, sections)
        }
        
        // Less than existing years
        if i == 0 && self.years[i].year != year {
            return (0, 0)
        }
        
        let (row, section) = self.years[i].rowAndSectionFor(date, components: components)
        return (row, section + sections)
        
        
        
    }
    
    func get(section: Int) -> [Trip]? {
        
        if tripCount == 0 {
            return nil
        }
        
        // If the given section is out of bounds, returns the next closest
        var section = section
        if section >= self.sectionCount {
            section = sectionCount-1
        }
        if section < 0 {
            section = 0
        }
        
        
 
        var i = 0
        var sectionCount = self.years[i].sectionCount
        while section >= sectionCount {
            i += 1
            sectionCount += self.years[i].sectionCount
        }
        sectionCount -= self.years[i].sectionCount
        return self.years[i].get(section: section - sectionCount)
    }
    
    // Check if number of trips is 0 before calling
    func get(row: Int, section: Int) -> Trip? {
      
        guard let trips = get(section: section) else {
            return nil
        }
        return trips[row]
    }
    
}


class Year: Codable {

    let year: Int
    var months: [Month] = []
    var sectionCount: Int = 0
    var tripCount: Int = 0
    
    init(year: Int) {
        self.year = year
    }
    
    
    // Returns the index of the given month. If the month doesn't exist, returns the index of the next highest month
    func getIndex(_ date: DateComponents) -> (Int, Int)? {
        
        // Param month is less than any month in year
        if self.months.count > 0 && self.months[0].month > date.month! {
            return (0, 0)
        }
        
        var i = 0
        while i < self.months.count && self.months[i].month < date.month! {
            i += 1
        }
        if i == self.months.count {
            return nil
        }
        if let day = self.months[i].getIndex(date) {
            return (i, day)
        }
        i += 1
        if i == self.months.count {
            return nil
        }
        return (i, 0)
        
        
        
    }
    
    /*
     * Adds a trip to the data structure
     * Similar to add function except instead of adding to the end it can be inserted anywhere
     * Returns true if a new day was added, false otherwise
     */
    @discardableResult func insert(_ trip: Trip, components: DateComponents) -> Bool {
        
        self.tripCount += 1
        let month = components.month!
        
        var i = 0
        while i < self.months.count && month < self.months[i].month {
            i += 1
        }
        
        if i < self.months.count && self.months[i].month == month {
            // Add to existing month
            if !self.months[i].insert(trip, components: components) {
                return false
                
            }
        } else {
            
            i = i == 0 || (i == self.months.count && self.months[i-1].month < month) ? i : i-1
            
            // Need to add a new month and day (section)
            self.months.insert(Month(month: month), at: i)
            self.months[i].add(trip, components: components)
        }
        
        self.sectionCount += 1
        
        return true
       
    }
    
    /*
     * Adds a trip to the data structure
     * Returns true if a new day was added, false otherwise
     */
    @discardableResult func add(_ trip: Trip, components: DateComponents) -> Bool {
        
        self.tripCount += 1
        let month = components.month!
        
        if let last = self.months.last, last.month == month {
            if !last.add(trip, components: components) {
                return false
            }
            
        } else {
            self.months.append(Month(month: month))
            self.months.last!.add(trip, components: components)
        }

        self.sectionCount += 1
        
        
        return true
    }
    
    func rowAndSectionFor(_ date: Date, components: DateComponents) -> (Int, Int) {
        let month = components.month!
        var i = 0
        var sections = 0
        while i < self.months.count && self.months[i].month < month {
            sections += self.months[i].days.count
            i += 1
        }
        
        
        // Greater than existing months
        if i == self.months.count {
            return (0, sections)
        }
        
        // Less than existing months
        if i == 0 && self.months[i].month != month {
            return (0, 0)
        }
        
        let (row, section) = self.months[i].rowAndSectionFor(date, components: components)
        return (row, section + sections)
    }
    
    func get(section: Int) -> [Trip] {
        var i = 0
        var sectionCount = self.months[i].days.count
        while section >= sectionCount {
            i += 1
            sectionCount += self.months[i].days.count
        }
        sectionCount -= self.months[i].days.count
        return self.months[i].get(section: section - sectionCount)
    }
    
}

class Month: Codable {
    
    let month: Int
    var days: [Day] = []
    var tripCount: Int = 0
    
    init(month: Int) {
        self.month = month
    }
    
    // Returns the index of the given day. If the day doesn't exist, returns the index of the next highest day
    func getIndex(_ date: DateComponents) -> Int? {
        var i = 0
        while i < self.days.count && self.days[i].day < date.day! {
            i += 1
        }
        if i == self.days.count {
            return nil
        }
        return i
        
    }
    
    
    /*
     * Adds a trip to the data structure
     * Similar to add function except instead of adding to the end it can be inserted anywhere
     * Returns true if a new day was added, false otherwise
     */
    @discardableResult func insert(_ trip: Trip, components: DateComponents) -> Bool {
        
        self.tripCount += 1
        let day = components.day!
        
        var i = 0
        while i < self.days.count && day < self.days[i].day {
            i += 1
        }
        
        if i < self.days.count && self.days[i].day == day {
            // Add to existing day
            self.days[i].insert(trip)
            return false
        } else {
            
            i = i == 0 || (i == self.days.count && self.days[i-1].day < day) ? i : i-1
            
            // Need to add a new day (section)
            self.days.insert(Day(day: day), at: i)
            self.days[i].add(trip)
            return true
        }
        
       
    }
    
    /*
     * Adds a trip to the data structure
     * Returns true if a new day was added, false otherwise
     */
    @discardableResult func add(_ trip: Trip, components: DateComponents) -> Bool {
        
        self.tripCount += 1
        let day = components.day!
        
        
        if let last = self.days.last, last.day == day {
            last.add(trip)
            return false
        } else {
            self.days.append(Day(day: day))
            self.days.last!.add(trip)
            return true
        }
    }
    
    func rowAndSectionFor(_ date: Date, components: DateComponents) -> (Int, Int) {
        let day = components.day!
        var i = 0
        var sections = 0
        while i < self.days.count && self.days[i].day < day {
            sections += 1
            i += 1
        }
        
        // Greater than existing days
        if i == self.days.count {
            return (0, sections)
        }
        
        // Less than existing days
        if i == 0 && self.days[i].day != day {
            return (0, 0)
        }
        
        return (self.days[i].rowFor(date), sections)
    }
    
    func get(section: Int) -> [Trip] {
        return self.days[section].trips
    }
}

class Day: Codable {
   
    let day: Int
    var trips: [Trip] = []
    
    init(day: Int) {
        self.day = day
    }
    
    /*
     * Adds a trip to the data structure
     * Similar to add function except instead of adding to the end it can be inserted anywhere
     */
    func insert(_ trip: Trip) {
        
        
        var i = 0
        while i < self.trips.count && trip.startDate < self.trips[i].startDate {
            i += 1
        }
        
        i = i == 0 || (i == self.trips.count && self.trips[i-1].startDate < trip.startDate) ? i : i-1
        
        self.trips.insert(trip, at: i)
       
    }
    
    /*
     * Adds a trip to the data structure
     */
    func add(_ trip: Trip) {
        trips.append(trip)
    }
    
    func rowFor(_ date: Date) -> Int {
        var i = 0
        var rows = 0
        while i < self.trips.count && self.trips[i].startDate < date {
            rows += 1
            i += 1
        }
        return rows
    }
    
}



class Trip: Codable  {
    
    var start: Location
    var startDate: Date
    var end: Location
    var endDate: Date
    var distance: Double
    
    /* * Initializers * */
    
    init(startDate: Date, endDate: Date, route: MKRoute) {
        
        self.start = Location(route.steps[0].polyline.points()[0])
        self.startDate = startDate
        self.end = Location(route.steps.last!.polyline.points()[0])
        self.endDate = endDate
        self.distance = route.distance
    }
    
    
    /* * Codable * */
    
    enum CodingKeys: String, CodingKey {
        case start
        case startDate
        case end
        case endDate
        case distance
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(start, forKey: .start)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(end, forKey: .end)
        try container.encode(endDate, forKey: .endDate)
        try container.encode(distance, forKey: .distance)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.start = try values.decode(Location.self, forKey: .start)
        self.startDate = try values.decode(Date.self, forKey: .startDate)
        self.end = try values.decode(Location.self, forKey: .end)
        self.endDate = try values.decode(Date.self, forKey: .endDate)
        self.distance = try values.decode(Double.self, forKey: .distance)
    }
    
}




struct ResponseData: Codable {
    var components: Components
}


struct Location: Codable {
    let latitude: Double
    let longitude: Double
    
    init(_ point: MKMapPoint) {
        self.init(point.coordinate)
    }
    
    init(_ location: CLLocation) {
        self.init(location.coordinate)
    }
    
    init(_ coords: CLLocationCoordinate2D) {
        self.latitude = coords.latitude
        self.longitude = coords.longitude
    }
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
