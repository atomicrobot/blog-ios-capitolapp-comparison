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
            List {
                ForEach(viewModel.capitalData, id: \.state.name) { stateDistancePair in
                    
                    let region = MKCoordinateRegion.zoom(initialRegion: MKCoordinateRegion(coordinates: [CLLocationCoordinate2D(latitude: Double(stateDistancePair.state.lat)!, longitude: Double(stateDistancePair.state.long)!), viewModel.userLocation])!)

                    NavigationLink {
                        MapView(state: stateDistancePair.state,
                                region: region,
                                cityAnnotation: idLocation(name: stateDistancePair.state.capital,
                                                           latitude: Double(stateDistancePair.state.lat)!,
                                                           longitude: Double(stateDistancePair.state.long)!))
                        .navigationTitle(stateDistancePair.state.abbreviation)
                    } label: {
                        VStack {
                            HStack {
                                Text(stateDistancePair.state.name)
                                Spacer()
                            }
                            HStack {

                                Text("\(stateDistancePair.state.capital) \(String(stateDistancePair.distanceInKilometers)) km away ").font(.footnote)
                                Spacer()
                            }
                        }
                    }.accessibilityIdentifier(stateDistancePair.state.abbreviation)
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
        }.ignoresSafeArea(edges: .bottom)
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
