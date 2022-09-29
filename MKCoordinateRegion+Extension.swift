//
//  MKCoordinateRegion+Extensions.swift
//  CapitolApp
//
//  Created by Bret Leupen on 9/29/22.
//
import Foundation
import MapKit
import CoreLocation

extension MKCoordinateRegion {

    init?(coordinates: [CLLocationCoordinate2D]) {

        // first create a region centered around the prime meridian
        let primeRegion = MKCoordinateRegion.region(for: coordinates, transform: { $0 }, inverseTransform: { $0 })

        // next create a region centered around the 180th meridian
        let transformedRegion = MKCoordinateRegion.region(for: coordinates, transform: MKCoordinateRegion.transform, inverseTransform: MKCoordinateRegion.inverseTransform)

        // return the region that has the smallest longitude delta
        if let a = primeRegion,
            let b = transformedRegion,
            let min = [a, b].min(by: { $0.span.longitudeDelta < $1.span.longitudeDelta }) {
            self = min
        } else if let a = primeRegion {
            self = a
        } else if let b = transformedRegion {
            self = b
        } else {
            return nil
        }
    }

    public static func makeSpan(latDelta: Double, longDelta: Double) -> MKCoordinateSpan? {
        if let latDegrees = CLLocationDegrees(exactly: latDelta), let longDegrees = CLLocationDegrees(exactly: longDelta) {
            let span = MKCoordinateSpan(latitudeDelta: latDegrees, longitudeDelta: longDegrees)
            return span
        }
        return nil
    }

    // Latitude -180...180 -> 0...360
    private static func transform(c: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        if c.longitude < 0 { return CLLocationCoordinate2DMake(c.latitude, 360 + c.longitude) }
        return c
    }

    // Latitude 0...360 -> -180...180
    private static func inverseTransform(c: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        if c.longitude > 180 { return CLLocationCoordinate2DMake(c.latitude, -360 + c.longitude) }
        return c
    }

    private typealias Transform = (CLLocationCoordinate2D) -> (CLLocationCoordinate2D)

    private static func region(for coordinates: [CLLocationCoordinate2D], transform: Transform, inverseTransform: Transform) -> MKCoordinateRegion? {
        // handle empty array
        if coordinates.isEmpty { return nil }

        // handle single coordinate
        guard coordinates.count > 1 else {
            guard let span = makeSpan(latDelta: 0.0125, longDelta: 0.0125) else { return nil }
            return MKCoordinateRegion(center: coordinates[0], span: span)
        }

        let transformed = coordinates.map(transform)

        // find the span
        let buffer = 0.00125

        let minLat = transformed.min { $0.latitude < $1.latitude }!.latitude - buffer
        let maxLat = transformed.max { $0.latitude < $1.latitude }!.latitude + buffer
        let minLon = transformed.min { $0.longitude < $1.longitude }!.longitude - buffer
        let maxLon = transformed.max { $0.longitude < $1.longitude }!.longitude + buffer
        guard let span = makeSpan(latDelta: maxLat - minLat, longDelta: maxLon - minLon) else { return nil }

        // find the center of the span
        let center = inverseTransform(CLLocationCoordinate2DMake((maxLat - span.latitudeDelta / 2), maxLon - span.longitudeDelta / 2))

        return MKCoordinateRegion(center: center, span: span)
    }

    static func zoom(initialRegion: MKCoordinateRegion) -> MKCoordinateRegion {
        let initialSpan = initialRegion.span
        let updatedSpan = MKCoordinateSpan(latitudeDelta: initialSpan.latitudeDelta * 1.2, longitudeDelta: initialSpan.longitudeDelta * 1.2)
        return MKCoordinateRegion(center: initialRegion.center, span: updatedSpan)
    }
}
