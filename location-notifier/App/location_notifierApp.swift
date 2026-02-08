//
//  location_notifierApp.swift
//  location-notifier
//
//  Created by Max on 2026-01-31.
//

import SwiftUI
import AVFoundation

@main
struct location_notifierApp: App {
    @State private var locationManager = LocationManager()
    @State private var alarmManager = AlarmManager()
    
    var body: some Scene {
        WindowGroup {
            TestView()
                .environment(locationManager)
                .environment(alarmManager)
            AlarmsView()
                .environment(locationManager)
                .environment(alarmManager)
                
        }
    }
}
