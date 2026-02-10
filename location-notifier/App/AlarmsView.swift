//
//  AlarmsView.swift
//  location-notifier
//
//  Created by Max on 2026-02-02.
//

import SwiftUI
import MapKit


func makeWrappedNotification(alarmManager: AlarmManager) -> ((CLRegion) -> Void) {
    return { _ in
        alarmManager.play_alarm()
    }
}

struct AlarmsView: View {
    @Environment(LocationManager.self) var locationManager
    @Environment(AlarmManager.self) var alarmManager
    @State private var alarms: [Alarm] = []
    var monitoredAlarms: [Alarm] = []
    
    var body: some View {
        VStack {
            ForEach($alarms, id: \.id) { $alarm in
                AlarmCard(alarm: $alarm)
            }
            Button {
                alarms.append(Alarm())
            } label: {
                Image(systemName: "plus")
            }
        }
        .onAppear {
            locationManager.subscribe(callback: makeWrappedNotification(alarmManager: alarmManager))
        }
        .onChange(of: alarms) { oldAlarms, newAlarms in
            let newGeofences = newAlarms.map { ($0.area) }
            locationManager.syncGeofences(newGeofences: Set(newGeofences))
        }
    }
}

struct AlarmCard: View {
    @Binding var alarm: Alarm
    @State private var isShowingMap = false
    
    var body: some View {
        HStack {
            TextField("Name", text: $alarm.name)
                .font(.headline)
            Text("Lat: \(alarm.area.center?.latitude ?? 0.0, specifier: "%.4f") Long: \(alarm.area.center?.longitude ?? 0.0, specifier: "%.4f")")
            Button {
                isShowingMap = true
            } label: {
                Image(systemName: "mappin.and.ellipse")
            }
        }
        .fullScreenCover(isPresented: $isShowingMap) {
            GeofencePickerView(selectedArea: $alarm.area)
        }
    }
}

