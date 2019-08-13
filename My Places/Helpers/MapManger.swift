//
//  MapManger.swift
//  My Places
//
//  Created by Степан on 13.08.2019.
//  Copyright © 2019 Stepan. All rights reserved.
//

import UIKit
import MapKit

class MapManger {
    
    let locationManger = CLLocationManager()
    
    private var placeCoordinate: CLLocationCoordinate2D?
    private let regionInMeters = 1000.0
    private var directionsArray: [MKDirections] = []
    
    func setupPlacemark(place: Place, mapView: MKMapView) {
        
        guard let location = place.location else { return }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = place.name
            annotation.subtitle = place.type
            
            guard let placemarkLocation = placemark?.location else { return }
            
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
            
        }
        
    }
    
    func checkLocationServices(mapView: MKMapView, segueIdentifire: String, closeure: () -> ()) {
        
        if CLLocationManager.locationServicesEnabled() {
            locationManger.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorization(mapView: mapView, incomeSegueIdentifier: segueIdentifire)
            closeure()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                self.showAlert(title: "Location Services are Disabled",
                               massage: "To enable it go to: Setting -> Privacy -> Location Services and turn On")
            }
        }
    }
    
    func checkLocationAuthorization(mapView: MKMapView, incomeSegueIdentifier: String) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if incomeSegueIdentifier == "getAddress" { showUserLocation(mapView: mapView) }
            break
        case .denied:
            // Show alert controller
            showAlert(title: "Your Location is not Availeble",
                      massage: "To give permission Go to: Setting -> My Places -> Location")
            break
        case .notDetermined:
            locationManger.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .authorizedAlways:
            break
            
        }
    }
    
    func showUserLocation(mapView: MKMapView) {
        
        if let location = locationManger.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func getDirection(for mapView: MKMapView, previsionLocation: (CLLocation) -> ()) {
        
        guard let location = locationManger.location?.coordinate else {
            showAlert(title: "Error", massage: "Current location is not found")
            return
        }
        
        locationManger.startUpdatingLocation()
        previsionLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        guard let request = createDirectionsRequest(from: location) else {
            showAlert(title: "Error", massage: "Destination is not found")
            return
        }
        
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions, mapView: mapView)
        
        directions.calculate{ (response, error) in
            
            if let error = error {
                print(error)
            }
            
            guard let response = response else {
                self.showAlert(title: "Error", massage: "Directin is not available")
                return
            }
            
            for rout in response.routes {
                mapView.addOverlay(rout.polyline)
                mapView.setVisibleMapRect(rout.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f", rout.distance / 1000)
                let timeInterval = rout.expectedTravelTime
                
                print("Расстояние до места: \(distance) км.")
                print("Время в пити составит: \(timeInterval) сек.")
            }
        }
        
    }
    
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
        guard let destinationCoordinate = placeCoordinate else { return nil}
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    func startTrackingUserLocation(for mapView: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()) {
        
        guard let previousLocation = location else { return }
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: previousLocation) > 50 else {return}
        
        closure(center)
        
    }
    
    func resetMapView(withNew directions: MKDirections, mapView: MKMapView) {
        
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
        directionsArray.removeAll()
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func showAlert(title: String, massage: String){
        let alert = UIAlertController(title: title,
                                      message: massage,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true)
        
    }
    
}
