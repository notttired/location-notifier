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
    var settings: AlarmSettings = AlarmSettings()
}

enum RepeatMode: String, CaseIterable, Identifiable {
    case never = "Never"
//    case daily
//    case weekly
    case always = "Always"
    var id: String { self.rawValue }
}

struct AlarmSettings: Equatable, Hashable {
    var active = true
    var repeatMode: RepeatMode = .always
}
