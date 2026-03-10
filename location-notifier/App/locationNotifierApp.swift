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
            AppView()
        }
    }
}

struct AppView: View {
    @State private var locationManager = LocationManager()
    @State private var alarmManager = AlarmManager()
    @State private var showHelp = false
    
    var body: some View {
        NavigationStack {
            VStack {
//                TitleView()
//                TestView()
                AlarmsView()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        HelpView()
                    } label: {
                        Image(systemName: "questionmark")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .environment(locationManager)
            .environment(alarmManager)
        }
    }
}

struct HelpView: View {
    var body: some View {
        Text("Swipe to delete")
    }
}

struct SettingsView: View {
    var body: some View {
        
    }
}

#Preview {
    AppView()
}
