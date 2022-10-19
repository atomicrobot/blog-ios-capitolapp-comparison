import Foundation
import CoreLocation
import Combine

struct DisplayedState {
    let state: USState
    let stateName: String
    let formattedCapitalDistance: String
}

class ViewModel: ObservableObject {
    private let currentLocationClient: CurrentLocationClient
    private let apiClient: ApiClient
    
    var userLocation: CLLocation?
    private var stateModel: StateModel?
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var states: [DisplayedState] = []
    
    init(currentLocationClient: CurrentLocationClient, apiClient: ApiClient) {
        self.currentLocationClient = currentLocationClient
        self.apiClient = apiClient

        cancellables.insert(startTrackingDistanceFromStateCapitals().replaceError(with: []).sink {_ in})
    }
    
    func startTrackingDistanceFromStateCapitals() -> AnyPublisher<[DisplayedState], Error> {

            self.apiClient.loadUSStates().combineLatest(self.currentLocationClient.startTrackingCurrentLocation())
                .map { (stateData: StateModel, currentLocation: CLLocation) in
                    self.userLocation = currentLocation
                    self.stateModel = stateData
                    DispatchQueue.main.async {
                        self.states = stateData.data.map { state in
                            let capitalLocation = state.capitalLocation
                            let distance = Int(currentLocation.distance(from: capitalLocation) / 1000)
                            let formattedCapitalDistance = state.capital + "  \(distance) km away"
                            return DisplayedState(state: state, stateName: state.name, formattedCapitalDistance: formattedCapitalDistance)
                        }
                    }
                    return self.states
                }.eraseToAnyPublisher()
        }
    
    func stopTrackingDistanceFromStateCapitals() {
        self.currentLocationClient.stopTrackingCurrentLocation()
    }
}
