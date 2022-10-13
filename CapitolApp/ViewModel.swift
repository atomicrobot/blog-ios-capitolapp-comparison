import Foundation
import CoreLocation

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
    
    func startTrackingDistanceFromStateCapitals(_ statesDataChanged: @escaping () -> ()) {
        // Load our state info
        self.apiClient.loadUStates { result in
            switch result {
            case .failure(let error):
                print(error)
                break
            case .success(let result):
                self.stateModel = result
                self.dataChanged(statesDataChanged)
                break
            }
        }
        
        // Start watching our current location
        self.currentLocationClient.startTrackingCurrentLocation { result in
            switch result {
            case .failure(let error):
                print(error)
                break
            case .success(let result):
                self.userLocation = result
                self.dataChanged(statesDataChanged)
                break
            }
        }
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
