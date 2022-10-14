import Foundation
import CoreLocation
import Combine

struct DisplayedState {
    let state: State
    let stateName: String
    let formattedCapitalDistance: String
}

class ViewModel {
    private let currentLocationClient: CurrentLocationClient
    private let apiClient: ApiClient
    
    private var userLocation: CLLocation?
    private var stateModel: StateModel?
    
    var states: [DisplayedState] = []
    
    init(currentLocationClient: CurrentLocationClient, apiClient: ApiClient) {
        self.currentLocationClient = currentLocationClient
        self.apiClient = apiClient
    }
    
    func startTrackingDistanceFromStateCapitals() -> AnyPublisher<[DisplayedState], Error> {

        self.apiClient.loadUSStates().combineLatest(self.currentLocationClient.startTrackingCurrentLocation())
            .map { (stateData: StateModel, currentLocation: CLLocation) in
                self.userLocation = currentLocation
                self.stateModel = stateData
                self.states = stateData.data.map { state in
                    let capitalLocation = state.capitalLocation
                    let distance = Int(currentLocation.distance(from: capitalLocation) / 1000)
                    let formattedCapitalDistance = state.capital + "  \(distance) km away"
                    return DisplayedState(state: state, stateName: state.name, formattedCapitalDistance: formattedCapitalDistance)
                }
                return self.states
            }.eraseToAnyPublisher()
    }
    
    func stopTrackingDistanceFromStateCapitals() {
        self.currentLocationClient.stopTrackingCurrentLocation()
    }
    
    private func dataChanged(_ statesDataChanged: () -> ()) {
        // If we don't have our BOTH states AND current location, return an empty list
        if let stateModel = self.stateModel, let userLocation = self.userLocation {
            self.states = stateModel.data.map { state in
                let capitalLocation = state.capitalLocation
                let distance = Int(userLocation.distance(from: capitalLocation) / 1000)
                let formattedCapitalDistance = state.capital + "  \(distance) km away"
                return DisplayedState(state: state, stateName: state.name, formattedCapitalDistance: formattedCapitalDistance)
            }
        } else {
            self.states = []
        }
        
        statesDataChanged()
    }
}
