//
//  MapViewController.swift
//  CapitolApp
//
//  Created by Bret Leupen on 9/23/22.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    private let state: USState
    var mapView: MKMapView!
    

    init(state: USState) {
        self.state = state
        
        super.init(nibName: nil, bundle: nil)
    }

    required convenience init?(coder: NSCoder) {
        self.init(state: USState(abbreviation: "NO", name: "BadState", capital: "BadLand", lat: "0.0", long: "0.0"))
        }


    override func viewDidLoad() {
        mapView = MKMapView()
        mapView.delegate = self

        self.mapView.userTrackingMode = .follow
        self.mapView.showsUserLocation = true

        view = mapView
        navigationController?.view.backgroundColor = .white
        self.title = state.abbreviation
    }

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let cityCoords = CLLocationCoordinate2D(latitude: Double(state.lat)!, longitude: Double(state.long)!)
        let cityAnnotation = MKPointAnnotation()
        cityAnnotation.coordinate = cityCoords
        cityAnnotation.title = state.capital
        self.mapView.addAnnotation(cityAnnotation)

        self.mapView.region = MKCoordinateRegion.zoom(initialRegion: MKCoordinateRegion(coordinates: [cityCoords, userLocation.coordinate])!)
    }


}
