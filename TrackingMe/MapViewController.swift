//
//  MapViewController.swift
//  TrackingMe
//
//  Created by chaoyee on 2016/12/6.
//  Copyright © 2016年 charleshsu.co. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import CoreLocation
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let vc = ViewController()
    
    var snapshotLocations: [FIRDataSnapshot] = []
    
    let manager = CLLocationManager()
    
    var annotationsLocations: [Location] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Observe the data changed in Firebase
        ref.observe(FIRDataEventType.value, with: { (snapshot) in
            let snapshotLocations = snapshot.value as? [String : AnyObject] ?? [:]
            print("Snapshot has been changed!")
            print(snapshotLocations)
            
            // Clear Array annotationsLocations
            if !self.annotationsLocations.isEmpty {
                self.annotationsLocations.removeAll()
            }
            
            // Copy all locations data from snapshot to
            //   annotationsLocations (Array) for further processing.
            for location in snapshotLocations {
                // Screen out coordinate belongs to this user
                if location.key != userID {
                    print("userID: " + location.key)
                    print("username: " + (location.value["username"] as! String))
                    print(location.value["lati"] as! Double)
                    print(location.value["long"] as! Double)
                    print("-------------------")
                    
                    // Append location data to the Array annotationsLocations
                    self.annotationsLocations.append(Location(
                        userID: location.key,
                        username: location.value["username"] as! String,
                        lati: (location.value["lati"] as! Double).roundTo(6),
                        long: (location.value["long"] as! Double).roundTo(6)))
                    
                }
            }
            self.refrashAnnotations()
        })
        //
        manager.requestWhenInUseAuthorization()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        checkAuth()
        manager.startUpdatingLocation()
        
        mapView.userTrackingMode = .follow
        mapView.delegate = self
        
        print("Start updating location.....")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func refrashAnnotations() {
        // Remove all annotations on mapView
        mapView.removeAnnotations(mapView.annotations)
        
        // Add annotations on mapView
        for location in annotationsLocations {
            let annotation = MKPointAnnotation()
            annotation.title = location.username
            annotation.coordinate = CLLocationCoordinate2DMake(location.lati, location.long)
            mapView.addAnnotation(annotation)
        }
        
    }

    func checkAuth() {
        
        let status = CLLocationManager.authorizationStatus()
        
        if status == .denied {
            let alert = UIAlertController(title: "title", message: "please allow", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!
                        , options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (UIAlertAction) in
                print("cancel")
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func setMapRegion(for location: CLLocationCoordinate2D, animated: Bool){
        let viewRegion = MKCoordinateRegionMakeWithDistance(location, 1000, 1000)
        mapView.setRegion(viewRegion, animated: animated)
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let locValue: CLLocationCoordinate2D = manager.location!.coordinate
        lati = NSNumber(value: locValue.latitude)
        long = NSNumber(value: locValue.longitude)
        vc.writeData()
        
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
//    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//        
//        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
//        polylineRenderer.strokeColor = .black
//        polylineRenderer.lineWidth = 5
//        return polylineRenderer
//    }
}



