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
                ForEach(viewModel.capitalData.data, id: \.name) { state in
                    
                    let region = MKCoordinateRegion.zoom(initialRegion: MKCoordinateRegion(coordinates: [CLLocationCoordinate2D(latitude: Double(state.lat)!, longitude: Double(state.long)!), viewModel.userLocation.coordinate])!)

                    NavigationLink {
                        MapView(region: region,
                                cityAnnotation: idLocation(name: state.capital,
                                                           latitude: Double(state.lat)!,
                                                           longitude: Double(state.long)!)).navigationTitle(state.abbreviation)
                    } label: {
                        VStack {
                            HStack {
                                Text(state.name)
                                Spacer()
                            }
                            HStack {
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
