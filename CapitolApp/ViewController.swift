import UIKit
import MapKit

class ViewController: UITableViewController {
    private let viewModel = ViewModel(currentLocationClient: CurrentLocationClient(), apiClient: ApiClient())
    
    override func viewDidLoad() {
        navigationController?.view.backgroundColor = .white
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "StateCell")
        self.viewModel.startTrackingDistanceFromStateCapitals { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.viewModel.stopTrackingDistanceFromStateCapitals()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.states.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let state = self.viewModel.states[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "StateCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = state.stateName
        content.secondaryText = state.formattedCapitalDistance
        cell.contentConfiguration = content
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let state = self.viewModel.states[indexPath.row]
        let mapViewController = MapViewController(state: state.state)
        navigationController?.pushViewController(mapViewController, animated: true)
    }
}
