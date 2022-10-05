//
//  CapitolListViewModel.swift
//  CapitolApp
//
//  Created by Bret Leupen on 9/27/22.
//

import Foundation
import MapKit
import Combine

class CapitolListViewModel: ObservableObject {
    private let currentLocationManager = CurrentLocationManager()
    @Published var capitalData: [USStateDistance] = []
    @Published var userLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)

    private var jsonURL = URL(string: "https://raw.githubusercontent.com/atomicrobot/blog-ios-capitolapp-comparison/uikit-closure/data.json")!
    private let decoder = JSONDecoder()
    private var cancellables: Set<AnyCancellable> = []

    init() {

        cancellables.insert(loadUSStatesWithDistances().replaceError(with: []).sink { items in
                    DispatchQueue.main.async {
                        self.capitalData = items
                    }
                })

        cancellables.insert(getCurrentLocation().replaceError(with: CLLocation(latitude: 0, longitude: 0)).sink { items in
                    DispatchQueue.main.async {
                        self.userLocation = items.coordinate
                    }
                })
    }




    func loadUSStatesWithDistances() -> AnyPublisher<[USStateDistance], Error> {
        return loadUSStates().combineLatest(getCurrentLocation())
            .map { (states: StateModel, currentLocation: CLLocation) in
                return states.data.map { state in
                    let distance = Int(currentLocation.distance(from: state.getCapitolLocation()) / 1000)
                    return USStateDistance(state: state, distanceInKilometers: distance)
                }
            }
            .eraseToAnyPublisher()
    }

    func loadUSStates() -> AnyPublisher<StateModel, Error> {
        return URLSession.shared.dataTaskPublisher(for: self.jsonURL)
            .map { $0.data }
            .tryMap { try self.decoder.decode(StateModel.self, from: $0) }
            .mapError { return $0 }
            .eraseToAnyPublisher()
    }

    func getCurrentLocation() -> AnyPublisher<CLLocation, Error> {
        return currentLocationManager.getCurrentLocation()
            .flatMap { value -> AnyPublisher<CLLocation, Error> in
                switch value {
                case .currentLocation(let location):
                    return Just(location).setFailureType(to: Error.self).eraseToAnyPublisher()
                case .denied:
                    return Fail(error: NSError()).eraseToAnyPublisher()
                default:
                    return Empty(completeImmediately: true).eraseToAnyPublisher()
            }}
            .eraseToAnyPublisher()
    }


}


extension USState {
    func getCapitolLocation() -> CLLocation {
        return CLLocation(latitude: Double(self.lat)!, longitude: Double(self.long)!)
    }
}

struct USStateDistance {
    let state: USState
    let distanceInKilometers: Int
}

enum CurrentLocationStatus {
    case notDetermined
    case currentLocation(CLLocation)
    case denied
}


class CurrentLocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager: CLLocationManager = CLLocationManager()
    private let currentLocation = CurrentValueSubject<CurrentLocationStatus, Error>(.notDetermined)

    override init() {
    }

    func getCurrentLocation() -> some Publisher<CurrentLocationStatus, Error> {
        locationManager.delegate = self

        switch locationManager.authorizationStatus {

        case .notDetermined:
            currentLocation.send(.notDetermined)
            locationManager.requestWhenInUseAuthorization()

        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()

        case .authorizedAlways:
            locationManager.startUpdatingLocation()

        case .restricted:
           // no access
            currentLocation.send(.denied)

        case .denied:
            // no access
            currentLocation.send(.denied)

        default:
            currentLocation.send(.denied)

        }

        return currentLocation
    }

    // Callback for when the location manager changes authorization status
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch locationManager.authorizationStatus {

        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()

        case .authorizedAlways:
            locationManager.startUpdatingLocation()

        default:
            currentLocation.send(.denied)

        }    }

    // When the user location updates, reload the list
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation.send(.currentLocation(locations[0]))
    }

    // Error for location manager
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        currentLocation.send(completion: .failure(error))

    }


}

