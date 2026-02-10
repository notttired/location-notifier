//
//  locations.swift
//  location-notifier
//
//  Created by Max on 2026-02-02.
//

import SwiftUI
import MapKit

struct LocationArea: Equatable, Hashable {
    var location: CLLocationCoordinate2D?
    var radius: CLLocationDistance = 1000
    
    var isSet: Bool {
        location != nil
    }
    
    static func == (lhs: LocationArea, rhs: LocationArea) -> Bool {
        switch (lhs.location, rhs.location) {
        case (nil, nil):
            return lhs.radius == rhs.radius
        case let (l?, r?):
            return l.latitude == r.latitude && l.longitude == r.longitude && lhs.radius == rhs.radius
        default:
            return false
        }
    }

    func hash(into hasher: inout Hasher) {
        if let loc = location {
            hasher.combine(loc.latitude)
            hasher.combine(loc.longitude)
        } else {
            // Distinguish nil location from (0,0)
            hasher.combine("nil_location")
        }
        hasher.combine(radius)
    }
}

struct Alarm: Identifiable, Equatable, Hashable {
    var id: UUID = UUID()
    var name: String = "New Alarm"
    var area: LocationArea = LocationArea()
    
    static func == (lhs: Alarm, rhs: Alarm) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name && lhs.area == rhs.area
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(area)
    }
}
