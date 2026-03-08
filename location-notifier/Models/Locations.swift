//
//  locations.swift
//  location-notifier
//
//  Created by Max on 2026-02-02.
//

import SwiftUI
import MapKit

struct LocationArea: Equatable, Hashable {
    var center: CLLocationCoordinate2D?
    var radius: CLLocationDistance = 100
    
    var isSet: Bool {
        center != nil
    }
    
    static func == (lhs: LocationArea, rhs: LocationArea) -> Bool {
        switch (lhs.center, rhs.center) {
        case (nil, nil):
            return lhs.radius == rhs.radius
        case let (l?, r?):
            return l.latitude == r.latitude && l.longitude == r.longitude && lhs.radius == rhs.radius
        default:
            return false
        }
    }

    func hash(into hasher: inout Hasher) {
        if let loc = center {
            hasher.combine(loc.latitude)
            hasher.combine(loc.longitude)
        } else {
            hasher.combine("nil_location")
        }
        hasher.combine(radius)
    }
    
    func toMKCoordinateRegion() -> MKCoordinateRegion? {
        guard let center = center else { return nil }
        return MKCoordinateRegion(center: center, radius: radius)
    }
}

extension MKCoordinateRegion {
    init(center: CLLocationCoordinate2D, radius: Double) {
        self.init(
            center: center,
            latitudinalMeters: radius * 2,
            longitudinalMeters: radius * 2
        )
    }
}

struct SearchableMapItem: Identifiable {
    let id: UUID = UUID()
    let item: MKMapItem
}

struct SearchableCompletionItem: Identifiable {
    let id: UUID = UUID()
    let item: MKLocalSearchCompletion
}
