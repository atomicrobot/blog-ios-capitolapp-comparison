import UIKit
import MapKit

class ViewController: UITableViewController, CLLocationManagerDelegate {

    private var capitalData: StateModel = StateModel(data: [])
    private var locationManager: CLLocationManager = CLLocationManager()
    private var userLocation: CLLocation = CLLocation()
    private var jsonURL = URL(string: "https://raw.githubusercontent.com/atomicrobot/blog-ios-capitolapp-comparison/uikit-closure/data.json")!
    private let decoder = JSONDecoder()


    override func viewDidLoad() {
        navigationController?.view.backgroundColor = .white
        locationManager.delegate = self

        // Asynchronous call to retrieve the data
        Task{
            let (data, _) = try await URLSession.shared.data(from: jsonURL)
            self.capitalData = try decoder.decode(StateModel.self , from: data)

            // Register the table and check the user location authorization
            self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "StateCell")
            self.checkUserLocationAuthorization()

        }
    }

    // Define the number of rows in the table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return capitalData.data.count
    }

    // Set up each row in the table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StateCell", for: indexPath)
        var content = cell.defaultContentConfiguration()

        // Set the state name for the cell
        content.text = capitalData.data[indexPath.row].name

        // Get the capital location and find the distance in kilometers
        let capitalLocation : CLLocation = CLLocation(latitude: Double(capitalData.data[indexPath.row].lat)!, longitude: Double(capitalData.data[indexPath.row].long)!)
        let distance = Int(userLocation.distance(from: capitalLocation) / 1000)

        // Set the capital name and the user's distance from the capital
        content.secondaryText = capitalData.data[indexPath.row].capital + "  \(distance) km away"

        // Set and return the cell with the configured content
        cell.contentConfiguration = content
        return cell
    }

    // When a row has been tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // Load a MapViewController for that state and push to nav stack
        let mapViewController = MapViewController(state: capitalData.data[indexPath.row])
        navigationController?.pushViewController(mapViewController, animated: true)
       
    }



    // Location functions
    func checkUserLocationAuthorization()  {

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
        // Check the authorization status again
        checkUserLocationAuthorization()
    }

    // Callback for when the user location changes
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Update the user location and reload the table
        userLocation = locations[0]
        self.tableView.reloadData()
    }

    // Error for location manager
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }

}


