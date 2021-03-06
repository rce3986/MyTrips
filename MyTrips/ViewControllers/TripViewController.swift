//
//  TripViewController.swift
//  MyTrips
//
//  Created by Ryan Elliott on 7/24/21.
//

import UIKit
import MapKit

class TripViewController: UIViewController {

    
    @IBOutlet weak var tripButton: TripButton!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var activityIndicatorView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let manager: CLLocationManager = CLLocationManager()
    
    var start: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let parent = self.parent as! TabBarController

        // Manager
        self.manager.delegate = self
        self.manager.requestWhenInUseAuthorization()
        //self.manager.desiredAccuracy = 25
        
        // Map
        self.map.isZoomEnabled = false
        self.map.isScrollEnabled = false
        self.map.isPitchEnabled = false
        self.map.isRotateEnabled = false
        self.map.delegate = self
        
        // Arrange subviews
        self.view.bringSubviewToFront(self.tripButton)
        self.view.bringSubviewToFront(self.activityIndicatorView)
            
        // ActivityIndicator
        self.activityIndicator.stopAnimating()
        self.activityIndicatorView.alpha = 0
        
        // Start
        if let start = parent.data.start {

            self.start = CLLocation(
                coordinate: CLLocationCoordinate2D(
                    latitude: start.latitude,
                    longitude: start.longitude
                ),
                altitude: 0,    // doesn't matter right now
                horizontalAccuracy: self.manager.desiredAccuracy,
                verticalAccuracy: self.manager.desiredAccuracy,
                timestamp: start.date
            )
        } else {
            self.start = nil
        }
        
        // Set Region
        self.setRegion()
        
        
        
        // Test stuff
        /*
        // Some park 38.3268693 -109.8782592
        // Some airport 45.305557 -96.424721
        self.start = CLLocation(latitude: 38.3268693, longitude: -109.8782592)
        let endCoords = CLLocationCoordinate2D(latitude: 45.305557, longitude: -96.424721)
        
        self.showRouteOnMap(pickupCoordinate: self.start!.coordinate, destinationCoordinate: endCoords)
        */
        // TripButton
        self.tripButton.configure()
        let tripStarted = self.start != nil
        if tripStarted != self.tripButton.trip {
            self.tripButton.toggle()
        }
        
        // Do any additional setup after loading the view.
    }
    
    /* * Helpers * */
    
    // Returns true if the app has access to location services and false otherwise
    func enabled(_ manager: CLLocationManager) -> Bool {
        switch manager.authorizationStatus {
            case .authorizedAlways,
                 .authorizedWhenInUse:
                return true
            default:
                return false
        }
    }
    
    func toggleActivityIndicator() {
        if self.activityIndicator.isAnimating { // Stop animating
            print("stopping animation")
            self.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            self.activityIndicatorView.alpha = 0
        } else {                                // Start animating
            print("starting animation")
            self.activityIndicator.startAnimating()
            self.view.isUserInteractionEnabled = false
            self.activityIndicatorView.alpha = 0.8
        }
    }
    
    
    func setRegion() {
        guard let start = self.start else {
            return
        }
        self.map.setRegion(
            MKCoordinateRegion(
                center: start.coordinate,
                latitudinalMeters: 500,
                longitudinalMeters: 500
            ),
            animated: true
        )
        
    }

    /* * Alerts * */
    
    func requestLocationServices() {
        let alert = UIAlertController(title: "Error!", message: "Location services needs to be enabled to start a trip.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(
            title: "Settings",
            style: .default,
            handler: { _ in
        
                UIApplication.shared.open(NSURL(string: UIApplication.openSettingsURLString)! as URL)
            
            }
        ))
        
        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil
        ))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func promptDescription(_ trip: Trip) {
        
        let parent = self.parent as! TabBarController
        
        let alert = UIAlertController(title: "Trip Description", message: nil, preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { _ in })
        
        alert.addAction(UIAlertAction(
            title: "Done",
            style: .default,
            handler: { [unowned alert] _ in

                trip.setDescription(alert.textFields![0].text)
                
                // Add trip
                parent.data.tripData.add(trip)
                
                // Change start
                self.start = nil
                parent.data.start = nil
                tripsWrite(data: parent.data)
                
                // Reload
                parent.reloadData()
               
            }
        
        ))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func failedToCalculateRoute() {
        
        let alert = UIAlertController(title: "Error!", message: "Couldn't calculate route.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(
            title: "Ok",
            style: .default,
            handler: nil
        
        ))

        self.present(alert, animated: true, completion: nil)

    }
    
    func failedToFindLocation() {
        
        let alert = UIAlertController(title: "Error!", message: "Couldn't find location.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(
            title: "Ok",
            style: .default,
            handler: nil
        
        ))

        self.present(alert, animated: true, completion: nil)

    }
    
    /* * Actions * */

    @IBAction func tripButtonTapped(_ sender: TripButton) {
        
        if !sender.locationIsOn {
            self.requestLocationServices()
            return
        }

        self.toggleActivityIndicator()
        self.manager.requestLocation()

        // Most work will be done in the locationManager didUpdateLocations function

    }

}

extension TripViewController: CLLocationManagerDelegate {
    
    // When new location is retrieved
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let loc = manager.location else {
            self.toggleActivityIndicator()
            self.failedToFindLocation()
            return
        }

        if let start = self.start {   // Trip was just ended
            
            addLocation(loc, map: self.map)
            
            route(start: start, end: loc, onSuccess: { route in
                
                    //show on map
                    self.map.addOverlay(route.polyline)
                    
                    //set the map area to show the route
                    self.map.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets.init(top: 80.0, left: 20.0, bottom: 100.0, right: 20.0), animated: true)
                    
                    //prompt description for trip, add trip on close
                    self.promptDescription(Trip(
                        start: start,
                        end: loc,
                        distance: route.distance
                    ))
                    
                    // change tripButton
                    self.tripButton.toggle()
                    
            }, onFailure: self.failedToCalculateRoute)
            
        } else { // Trip was just started
            
            let parent = self.parent as! TabBarController
            
            // Clear map
            self.map.removeOverlays(self.map.overlays)
            self.map.removeAnnotations(self.map.annotations)
        
            // Change start
            self.start = loc
            parent.data.start = Location(location: loc)
            tripsWrite(data: parent.data)
            
            // Show location
            addLocation(loc, map: self.map)
            self.setRegion()
            
            // Change tripbutton
            self.tripButton.toggle()
        }
        
        self.toggleActivityIndicator()
    }

    // When the authorization status of the app is changed
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.tripButton.locationIsOn = self.enabled(manager)
    }
    
    // When manager fails
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        
        self.failedToFindLocation()
        print(error)
    }
}

extension TripViewController: MKMapViewDelegate {
    //this delegate function is for displaying the route overlay and styling it
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 5.0
        return renderer
    }
}
