import UIKit
import MapKit

class ViewController: UITableViewController, CLLocationManagerDelegate {

    var sampleData: StateModel = StateModel(data: [])
    var locationManager: CLLocationManager = CLLocationManager()
    var userLocation: CLLocation = CLLocation()


    override func viewDidLoad() {
        locationManager.delegate = self

        /// TODO Load JSON from network with closure instead of locally
        let path = Bundle.main.path(forResource: "data", ofType: "json") ?? ""
        let data  = try! Data(contentsOf: URL(filePath: path))
        sampleData = try! JSONDecoder().decode(StateModel.self, from: data)

        refreshLocation()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "StateCell")
    }

    func loadList() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "StateCell")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sampleData.data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StateCell", for: indexPath)
        var content = cell.defaultContentConfiguration()

        content.text = sampleData.data[indexPath.row].name

        //CLLocationCoordinate2D(latitude: Double(sampleData.data[indexPath.row].lat)!, longitude: Double(sampleData.data[indexPath.row].long)!)
        let capitalLocation : CLLocation = CLLocation(latitude: Double(sampleData.data[indexPath.row].lat)!, longitude: Double(sampleData.data[indexPath.row].long)!)
        let distance = Int(userLocation.distance(from: capitalLocation) / 1000)

        content.secondaryText = sampleData.data[indexPath.row].capital + "  \(distance) km away"


        cell.contentConfiguration = content
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let capitalLocation : CLLocation = CLLocation(latitude: Double(sampleData.data[indexPath.row].lat)!, longitude: Double(sampleData.data[indexPath.row].long)!)
        let distance = userLocation.distance(from: capitalLocation)
        let mapViewController = MapViewController(state: sampleData.data[indexPath.row], userDistance: distance)
        navigationController?.pushViewController(mapViewController, animated: true)
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
        userLocation = locations[0]
        loadList()
    }

    // Error for location manager
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")

    }

}


