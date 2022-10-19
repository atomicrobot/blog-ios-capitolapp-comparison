import Foundation
import CoreLocation
import Combine

protocol CurrentLocationClientDelegate: AnyObject {
    func currentLocationUpdated(currentLocation: CLLocation)
    func currentLocationError(error: CurrentLocationError)
}

enum CurrentLocationError: Error {
    case currentLocationNotAvailable
    case currentLocationError(_ error: Error)
}

class CurrentLocationClient: NSObject {
    private let locationManager = CLLocationManager()
    private let currentLocation = CurrentValueSubject<CLLocation, Error>(CLLocation())
    
    func startTrackingCurrentLocation() -> AnyPublisher<CLLocation, Error> {
        locationManager.delegate = self
        locationManager.distanceFilter = kCLLocationAccuracyHundredMeters
        
        locationManager.requestWhenInUseAuthorization()

        DispatchQueue.global(qos: .background).async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.startUpdatingLocation()
            }
        }

        return currentLocation.eraseToAnyPublisher()
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
            currentLocation.send(completion: Subscribers.Completion<Error>.failure(CurrentLocationError.currentLocationNotAvailable))
        } else if (status == .authorizedWhenInUse || status == .authorizedAlways) {
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation.send(locations[0])
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        currentLocation.send(completion: Subscribers.Completion<Error>.failure(CurrentLocationError.currentLocationError(error)))
    }
}
