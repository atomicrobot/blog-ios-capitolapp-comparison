import Foundation
import CoreLocation

struct StateModel: Codable {
    let data : [State]
}

struct State: Codable {
    let abbreviation: String
    let name: String
    let capital: String
    let lat: String
    let long: String
}

extension State {
    var capitalLocation: CLLocation {
        return CLLocation(latitude: Double(lat)!, longitude: Double(long)!)
    }
}
