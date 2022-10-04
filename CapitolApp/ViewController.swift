import UIKit
import MapKit

class ViewController: UITableViewController, CLLocationManagerDelegate {

    var capitalData: StateModel = StateModel(data: [])
    var locationManager: CLLocationManager = CLLocationManager()
    var userLocation: CLLocation = CLLocation()

    private var jsonURL = URL(string: "https://raw.githubusercontent.com/atomicrobot/blog-ios-capitolapp-comparison/uikit-closure/data.json")
    private let decoder = JSONDecoder()


    override func viewDidLoad() {
        navigationController?.view.backgroundColor = .white
        locationManager.delegate = self

        let dataTask = URLSession.shared.dataTask(with: self.jsonURL!, completionHandler: { (data, response, error) in

            DispatchQueue.main.async {

                // handle errors
                if let error = error {
                    print("Error with fetching State Data: \(error)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    print("Error with the response, unexpected status code: \(String(describing: response))")
                    return
                }

                // decode and load table
                self.capitalData = try! self.decoder.decode(StateModel.self, from: data!)
                self.tableView.reloadData()
                self.refreshLocation()
                self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "StateCell")
            }


        })

        dataTask.resume()


    }

    func loadList() {
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "StateCell")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return capitalData.data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StateCell", for: indexPath)
        var content = cell.defaultContentConfiguration()

        content.text = capitalData.data[indexPath.row].name

        //CLLocationCoordinate2D(latitude: Double(sampleData.data[indexPath.row].lat)!, longitude: Double(sampleData.data[indexPath.row].long)!)
        let capitalLocation : CLLocation = CLLocation(latitude: Double(capitalData.data[indexPath.row].lat)!, longitude: Double(capitalData.data[indexPath.row].long)!)
        let distance = Int(userLocation.distance(from: capitalLocation) / 1000)

        content.secondaryText = capitalData.data[indexPath.row].capital + "  \(distance) km away"


        cell.contentConfiguration = content
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {


        let mapViewController = MapViewController(state: capitalData.data[indexPath.row])
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


