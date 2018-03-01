//
//  CoordinatesViewController.swift
//  iss-passes
//
//  Created by Devin Marks on 2/28/18.
//  Copyright © 2018 Devin Marks All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class CoordinatesViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var issLocationButton: UIButton!
    @IBOutlet weak var showAllButton: UIButton!
    
    @IBAction func myLocationButtonAction(_ sender: Any) {
        FocusOnUserLocation()
    }
    @IBAction func issLocationButtonAction(_ sender: Any) {
        GetCurrentISSLocation(showAll: false)
        FocusOnISSLocation()
    }
    @IBAction func showAllButtonAction(_ sender: Any) {
        FocusOnBothLocations()
    }
    
    var locationManager: CLLocationManager!
    
    var currentUserLatitude: Double = 0.0
    var currentUserLongitude: Double = 0.0
    var issCurrentLatitude: Double = 0.0
    var issCurrentLongitude: Double = 00
    var userAnnotation = MKPointAnnotation()
    var issAnnotation = MKPointAnnotation()
    var userLocation = CLLocationCoordinate2D()
    var issLocation = CLLocationCoordinate2D()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Location Manager to retrieve device GPS and request appropriate permissions
        locationManager = CLLocationManager()
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        // Ensure location services are enabled before performing tasks
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        } else {
            sendAlert(message: "Location Services Not Enabled. Enable Location Services in Privacy Settings")
        }
        
        // Load Initial Location of ISS and show both user location and ISS in view
        GetCurrentISSLocation(showAll: true)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // There is a bug in iOS 11 where the UIBarButtonItem stays highlighted after navigation
        // and does not return to its normal state after the other view controller pops.
        // Adjusting the tint back to normal is a workaround for this bug.
        self.navigationController?.navigationBar.tintAdjustmentMode = .normal
        self.navigationController?.navigationBar.tintAdjustmentMode = .automatic
    }
    
    // Update map with users device location using location manager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        manager.stopUpdatingLocation();
        
        SetLocationCoordinates(latitude,longitude)
        
    }
    
    // Catch error that may occur in Location Manager
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let nsError = error as NSError
        
        if(nsError.code == 1) {
            sendAlert(message: "Location Services disabled for application. Enable Location services in Privacy Settings for application.")
        } else {
            sendAlert(message: "GPS error detected. Retry in area with better reception")
        }
        
    }
    
    // Set the device location lattitude and longitude
    func SetLocationCoordinates(_ lat: Double, _ lon: Double){
        currentUserLatitude = lat
        currentUserLongitude = lon
        SetUserLocationonMap(lat,lon)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Pass user device coordinates to next view controller for network call
        if let tableviewController = segue.destination as? ISSTableViewController{
            tableviewController.userLatitude = currentUserLatitude
            tableviewController.userLongitude = currentUserLongitude
        }
        
    }
    
    // Set The Location of user on map with annotation
    func SetUserLocationonMap(_ lat: Double, _ lon: Double){
        userLocation = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        userAnnotation.coordinate = userLocation
        mapView.addAnnotation(userAnnotation)
        mapView.showAnnotations([userAnnotation], animated: true)
    }
    
    // Focus on user location on map
    func FocusOnUserLocation(){
        mapView.showAnnotations([userAnnotation], animated: true)
    }
    
    // Focus on ISS current location on map
    func FocusOnISSLocation(){
        mapView.showAnnotations([issAnnotation], animated: true)
    }
    
    // Focus on both user and ISS locations on map
    func FocusOnBothLocations(){
        mapView.showAnnotations([userAnnotation,issAnnotation], animated: true)
    }
    
    // Get Current ISS Location by calling ISS Location API
    func GetCurrentISSLocation(showAll:Bool){
        
        // Disable Buttons as system attempts to get latest ISS location
        self.issLocationButton.isEnabled = true
        self.showAllButton.isEnabled = true
        
        // Retrieve the current location of ISS and display on map
        getCurrentAsDictionary() { (issCurrentLocation) in
            print(issCurrentLocation)
            
            // Update UI on main thread
            DispatchQueue.main.async {
                
                if let issLatitude = Double(issCurrentLocation["latitude"] as! String), let issLongitude = Double(issCurrentLocation["longitude"] as! String) {
                    
                    self.issCurrentLatitude = issLatitude
                    self.issCurrentLongitude = issLongitude
                    
                    // Configure the annotation location on map for ISS
                    self.issLocation = CLLocationCoordinate2D(latitude: self.issCurrentLatitude, longitude: self.issCurrentLongitude)
                    self.issAnnotation.coordinate = self.issLocation
                    self.mapView.addAnnotation(self.issAnnotation)
                    self.issLocationButton.isEnabled = true
                    self.showAllButton.isEnabled = true
                    
                    // Either Focus on just the ISS location after load or on both user and ISS
                    if (showAll) {
                        self.FocusOnBothLocations()
                    } else {
                        self.FocusOnISSLocation()
                    }
                }
            }
        }
    }

}
