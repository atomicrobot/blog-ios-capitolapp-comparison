import UIKit
import MapKit
import Combine

class ViewController: UITableViewController {
    private let viewModel = ViewModel(currentLocationClient: CurrentLocationClient(), apiClient: ApiClient())
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        navigationController?.view.backgroundColor = .white
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "StateCell")
        cancellables.insert(self.viewModel.startTrackingDistanceFromStateCapitals().replaceError(with: []).sink { items in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.viewModel.stopTrackingDistanceFromStateCapitals()
    }

    // Number of sections in the table
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    // Number of rows in the table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.states.count
    }

    // Setup for each row
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let state = self.viewModel.states[indexPath.row]

        //Set the cell content to the corresponding state info
        let cell = tableView.dequeueReusableCell(withIdentifier: "StateCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = state.stateName
        content.secondaryText = state.formattedCapitalDistance
        cell.contentConfiguration = content
        return cell
    }

    // When a row is tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let state = self.viewModel.states[indexPath.row]

        // Create the MapViewController and push onto the nav stack
        let mapViewController = MapViewController(state: state.state)
        navigationController?.pushViewController(mapViewController, animated: true)
    }
}
