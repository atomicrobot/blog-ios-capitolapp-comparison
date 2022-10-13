import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    private let state: State
    private var mapView: MKMapView!

    init(state: State) {
        self.state = state        
        super.init(nibName: nil, bundle: nil)
    }

    required convenience init?(coder: NSCoder) {
        self.init(state: State(abbreviation: "NO", name: "Bad", capital: "Bad", lat: "0.0", long: "0.0"))
    }

    override func viewDidLoad() {
        mapView = MKMapView()
        mapView.delegate = self

        //self.mapView.userTrackingMode = .follow
        self.mapView.showsUserLocation = true

        self.view = mapView
        self.navigationController?.view.backgroundColor = .white
        self.title = state.abbreviation
    }

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {

        let capitalAnnotation = MKPointAnnotation()
        capitalAnnotation.coordinate = state.capitalLocation.coordinate
        capitalAnnotation.title = state.capital
        self.mapView.addAnnotation(capitalAnnotation)


        let region = MKCoordinateRegion(coordinates: [state.capitalLocation.coordinate, userLocation.coordinate])!
        self.mapView.region = MKCoordinateRegion.zoom(initialRegion: region)
    }
}
