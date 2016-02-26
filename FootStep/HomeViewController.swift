//
//  HomeViewController.swift
//  FootStep
//
//  Created by oyoung on 16/2/24.
//  Copyright © 2016年 oyoung. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

func dbg() {
    print(__FUNCTION__ + " : "+String(__LINE__))
}

class HomeViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locateButton: UIButton!
    @IBOutlet weak var enlargeButton: UIButton!
    @IBOutlet weak var shrinkButton: UIButton!
    
    var locationManager: CLLocationManager?
    var footprint: [(Double, Double)] = []
    var geocoder: CLGeocoder = CLGeocoder()

    override func viewDidLoad() {
        print(__FUNCTION__ + " : "+String(__LINE__))
        super.viewDidLoad()
        setupLocationManager(delegate: self)
        setupMapView(delegate: self)
       
    }
    
    override func viewWillAppear(animated: Bool) {
        print(__FUNCTION__ + " : "+String(__LINE__))
        super.viewWillAppear(animated)
        updateLocation()
       
    }
    
    func updateLocation() {
        print(__FUNCTION__ + " : "+String(__LINE__))
        if let lm = locationManager {
            if CLLocationManager.locationServicesEnabled() {
                lm.startUpdatingLocation()
            }
        }
    }
    
    
    func setupLocationManager(delegate d: CLLocationManagerDelegate) {
        print(__FUNCTION__ + " : "+String(__LINE__))
        locationManager = CLLocationManager()
        if let lm = locationManager {
            lm.delegate = d
            lm.desiredAccuracy = kCLLocationAccuracyBest
            lm.distanceFilter = 50
            lm.requestAlwaysAuthorization()
        }
    }
    
    func setupMapView(delegate d: MKMapViewDelegate) {
        print(__FUNCTION__ + " : "+String(__LINE__))
        mapView.delegate = d
        mapView.userTrackingMode = MKUserTrackingMode.FollowWithHeading
        mapView.mapType = .Standard
        center = mapView.centerCoordinate
        mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: false)
        
    }

    override func didReceiveMemoryWarning() {
        print(__FUNCTION__ + " : "+String(__LINE__))
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func locateTouchUpiside(sender: UIButton) {
        print(__FUNCTION__ + " : "+String(__LINE__))
        
        navigationItem.title = "正在定位..."
        
        updateLocation()
    }
    
    var span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    var center: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    @IBAction func largerTouch(sender: UIButton) {
        print(__FUNCTION__ + " : "+String(__LINE__))
        let la = span.latitudeDelta * 0.5
        let lo = span.longitudeDelta * 0.5
        span.latitudeDelta = max(la, 0.003125)
        span.longitudeDelta = max(lo, 0.003125)
        if la < 0.003125 {
            enlargeButton.enabled = false
        }
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
        shrinkButton.enabled = true
    }
    
    @IBAction func smallerTouch(sender: UIButton) {
        print(__FUNCTION__ + " : "+String(__LINE__))
        let la = span.latitudeDelta * 2
        let lo = span.longitudeDelta * 2
        span.latitudeDelta = min(la, 128)
        span.longitudeDelta = min(lo, 128)
        if la > 128 {
            shrinkButton.enabled = false
        }
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
        enlargeButton.enabled = true
    }
    
    func setLocationDescription(location: CLLocation?) {
        if let ln = location {
            geocoder.reverseGeocodeLocation(ln) { (placemarks, error) -> Void in
                guard let _ = error  else {
                    if let pm = placemarks?.first {
                        
                        self.navigationItem.title = pm.name
                    }
                    return
                }
            }
        }
    }

}

class Annotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
    
}

extension HomeViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation,fromLocation oldLocation: CLLocation) {
        print(__FUNCTION__ + " : "+String(__LINE__))
        let coordinate = newLocation.coordinate
        let longitude = coordinate.longitude
        let latitude = coordinate.latitude
        footprint.append((latitude, longitude))
        addAnnotation(newLocation)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(__FUNCTION__ + " : "+String(__LINE__))
        let newLocation = locations.last!
        let la = min(span.latitudeDelta, 0.1)
        let lo = min(span.longitudeDelta, 0.1)
        span = MKCoordinateSpan(latitudeDelta: la, longitudeDelta: lo)
        addAnnotation(newLocation)
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(__FUNCTION__ + " : "+String(__LINE__))
    }
    
    func addAnnotation(newLocation: CLLocation) {
        print(__FUNCTION__ + " : "+String(__LINE__))
        let anno = Annotation(coordinate: center, title: "我在这里", subtitle: nil)
        mapView.centerCoordinate = center
        mapView.region = MKCoordinateRegion(center: center, span: span)
        mapView.addAnnotation(anno)
    }
}


extension HomeViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        print(__FUNCTION__ + " : "+String(__LINE__))
        let isCustom = annotation.isKindOfClass(Annotation)
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier("ANNO")
        if view == nil {
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: "ANNO")
            view?.canShowCallout = true
        }
        return isCustom ? view : nil
//        return nil
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        print(__FUNCTION__ + " : "+String(__LINE__))
        if let center = userLocation.location?.coordinate {
            self.center = center
            let region = MKCoordinateRegionMake(center, span)
        
            mapView.setRegion(region, animated: true)
            setLocationDescription(userLocation.location)
        }
    }
}
