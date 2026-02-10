//
//  App.swift
//  location-notifier
//
//  Created by Max on 2026-02-09.
//

import SwiftUI

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
