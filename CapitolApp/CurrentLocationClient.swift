import Foundation
import CoreLocation

protocol CurrentLocationClientDelegate: AnyObject {
    func currentLocationUpdated(currentLocation: CLLocation)
    func currentLocationError(error: CurrentLocationError)
}

typealias CurrentLocationResult = Result<CLLocation, CurrentLocationError>

enum CurrentLocationError: Error {
    case currentLocationNotAvailable
    case currentLocationError(_ error: Error)
}

class CurrentLocationClient: NSObject {
    private let locationManager = CLLocationManager()
    
    private var completion: ((CurrentLocationResult) -> ())?
    
    func startTrackingCurrentLocation(_ completion: @escaping (CurrentLocationResult) -> ()) {
        locationManager.delegate = self
        locationManager.distanceFilter = kCLLocationAccuracyHundredMeters
        self.completion = completion
        
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func stopTrackingCurrentLocation() {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
    }
}

extension CurrentLocationClient: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = locationManager.authorizationStatus
        if (status == .restricted || status == .denied) {
            self.completion?(CurrentLocationResult.failure(CurrentLocationError.currentLocationNotAvailable))
        } else if (status == .authorizedWhenInUse || status == .authorizedAlways) {
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations[0]
        self.completion?(CurrentLocationResult.success(currentLocation))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.completion?(CurrentLocationResult.failure(CurrentLocationError.currentLocationError(error)))
    }
}
