//
//  SwiftUIView.swift
//  CapitolApp
//
//  Created by Bret Leupen on 10/13/22.
//

import SwiftUI
import MapKit

struct SwiftUIView: View {
    @StateObject private var viewModel: ViewModel

    init() {
        self._viewModel = StateObject(wrappedValue: ViewModel(currentLocationClient: CurrentLocationClient(), apiClient: ApiClient()))
    }


    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.states, id: \.stateName) { displayedState in

                    let region = MKCoordinateRegion.zoom(initialRegion: MKCoordinateRegion(coordinates: [CLLocationCoordinate2D(latitude: Double(displayedState.state.lat)!, longitude: Double(displayedState.state.long)!), viewModel.userLocation!.coordinate])!)

                    NavigationLink {
                        MapView(state: displayedState.state,
                                region: region,
                                cityAnnotation: idLocation(name: displayedState.state.capital,
                                                           latitude: Double(displayedState.state.lat)!,
                                                           longitude: Double(displayedState.state.long)!)).navigationTitle(displayedState.state.abbreviation)
                    } label: {
                        VStack {
                            HStack {
                                Text(displayedState.stateName)
                                Spacer()
                            }
                            HStack {
                                Text(displayedState.formattedCapitalDistance).font(.footnote)
                                Spacer()
                            }
                        }
                    }
                    .accessibilityIdentifier(displayedState.state.abbreviation)
                }
            }
        }
    }
}

struct MapView: View {
    let state: USState
    @State var region: MKCoordinateRegion
    let cityAnnotation: idLocation

    var body: some View {

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
