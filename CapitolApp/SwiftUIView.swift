//
//  CapitolListView.swift
//  CapitolApp
//
//  Created by Bret Leupen on 9/27/22.
//

import SwiftUI
import MapKit

struct SwiftUIView: View {
    @StateObject private var viewModel = CapitolListViewModel()

    init() {
        self._viewModel = StateObject(wrappedValue: CapitolListViewModel())
    }

    var body: some View {
        NavigationView {
            // Create a list will all the states
            List {
                // Loop thru all the states
                ForEach(viewModel.capitalData.data, id: \.name) { state in

                    // Create the region to display for each state using the user location and capital location
                    let region = MKCoordinateRegion.zoom(initialRegion: MKCoordinateRegion(coordinates: [CLLocationCoordinate2D(latitude: Double(state.lat)!, longitude: Double(state.long)!), viewModel.userLocation.coordinate])!)

                    // Each Row is a navigation link to a new view
                    NavigationLink {
                        MapView(region: region,
                                currentState: state ).navigationTitle(state.abbreviation)
                    } label: {
                        // Create the Label for each row in the list
                        VStack {
                            HStack {
                                Text(state.name)
                                Spacer()
                            }
                            HStack {
                                // Calculate and display the User's current location in reference to the capital
                                let capitalLocation : CLLocation = CLLocation(latitude: Double(state.lat)!, longitude: Double(state.long)!)
                                let distance = Int(viewModel.userLocation.distance(from: capitalLocation) / 1000)
                                Text("\(state.capital) \(String(distance)) km away ").font(.footnote)
                                Spacer()
                            }
                        }
                    }.accessibilityIdentifier(state.abbreviation)
                }
            }
        }
    }
}

struct MapView: View {
    @State var region: MKCoordinateRegion
    let currentState: USState


    var body: some View {
        let cityAnnotation: idLocation = idLocation(name: currentState.capital,
                                                    latitude: Double(currentState.lat)!,
                                                    longitude: Double(currentState.long)!)

        Map(coordinateRegion: self.$region, showsUserLocation: true, annotationItems: [cityAnnotation])
        { item in
            MapMarker(coordinate: CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude))
        }
    }
}

struct idLocation: Identifiable {
    let id = UUID()
    let name : String
    let latitude: Double
    let longitude: Double
}



struct CapitolListView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
