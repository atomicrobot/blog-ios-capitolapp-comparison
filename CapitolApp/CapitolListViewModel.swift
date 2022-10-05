//
//  CapitolListViewModel.swift
//  CapitolApp
//
//  Created by Bret Leupen on 9/27/22.
//

import Foundation
import MapKit

class CapitolListViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {

    private var jsonURL = URL(string: "https://raw.githubusercontent.com/atomicrobot/blog-ios-capitolapp-comparison/uikit-closure/data.json")
    private let decoder = JSONDecoder()
    @Published var capitalData: StateModel = StateModel(data: [])
    @Published var userLocation: CLLocation = CLLocation()
    let locationManager: CLLocationManager

    override init() {


        self.locationManager = CLLocationManager()
        super.init()
        self.locationManager.delegate = self

        // grab the data
        let ccDataTask = URLSession.shared.dataTask(with: self.jsonURL!, completionHandler: { (data, response, error) in
            // handle errors
            DispatchQueue.main.async {
                if let error = error {
                    print("Error with fetching Weather Data: \(error)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    print("Error with the response, unexpected status code: \(String(describing: response))")
                    return
                }

                self.capitalData = try! self.decoder.decode(StateModel.self, from: data!)
                self.refreshLocation()

            }


        })

        ccDataTask.resume()

    }


    // Location functions
    func refreshLocation()  {
        switch locationManager.authorizationStatus {

        case .notDetermined:
            // prompt the user
            print("Asking user")
            locationManager.requestWhenInUseAuthorization()

        case .authorizedWhenInUse:
            locationManager.requestLocation()

        case .authorizedAlways:
            locationManager.requestLocation()

        case .restricted:
           // no access
            print( "User denied location")

        case .denied:
            // no access
            print( "User denied location")

        default:
            print("default -- unknown")

        }

    }

    // Callback for when the location manager changes authorization status
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        refreshLocation()
    }

    // When the user location updates, reload the list
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.userLocation = locations[0]

    }

    // Error for location manager
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")

    }


}