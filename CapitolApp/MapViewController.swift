//
//  MapViewController.swift
//  CapitolApp
//
//  Created by Bret Leupen on 9/23/22.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    private let state: State
    private let userDistance: CLLocationDistance
    var mapView: MKMapView!

    init(state: State, userDistance: CLLocationDistance) {
        self.state = state
        self.userDistance = userDistance
        
        super.init(nibName: nil, bundle: nil)
    }

    required convenience init?(coder: NSCoder) {
        self.init(state: State(abbreviation: "NO", name: "Bad", capital: "Bad", lat: "0.0", long: "0.0"), userDistance: 1000.0)
        }

    /// TODO Add Abbreviation as title
    override func viewDidLoad() {
        mapView = MKMapView()
        let cityCoords = CLLocationCoordinate2D(latitude: Double(state.lat)!, longitude: Double(state.long)!)


        /// TODO Fix bounding box for user -- this seems to be a bit too large
        let span = MKCoordinateSpan(latitudeDelta: abs(cityCoords.latitude - mapView.userLocation.coordinate.latitude), longitudeDelta: abs(cityCoords.longitude - mapView.userLocation.coordinate.longitude))
        mapView.setCenter(cityCoords, animated: true)
        mapView.showsUserLocation = true
        let region = MKCoordinateRegion(center: cityCoords, span: span)
        mapView.setRegion(region, animated: true)

        view = mapView
    }
}
