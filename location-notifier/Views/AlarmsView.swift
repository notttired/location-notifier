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
            List {
                ForEach($alarms, id: \.id) { $alarm in
                    AlarmCard(alarm: $alarm)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteAlarm(id: alarm.id)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
                Button {
                    alarms.append(Alarm())
                } label: {
                    Image(systemName: "plus")
                }
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
    
    func deleteAlarm(id: UUID) {
        for (index, alarm) in alarms.enumerated() {
            if alarm.id == id {
                alarms.remove(at: index)
                return
            }
        }
    }
}

struct AlarmCard: View {
    @Binding var alarm: Alarm
    @State private var isShowingMap = false
    @State private var isShowingSettings = false
    
    var body: some View {
        HStack {
            TextField("Name", text: $alarm.name)
                .font(.headline)
            Toggle("", isOn: $alarm.settings.active)
            Button {
                isShowingSettings = true
            } label: {
                Image(systemName: "gear")
            }
            .buttonStyle(.plain)
            Button {
                isShowingMap = true
            } label: {
                Image(systemName: "mappin.and.ellipse")
            }
            .buttonStyle(.plain)
        }
        .navigationDestination(isPresented: $isShowingSettings) {
                    AlarmSettingsView(settings: $alarm.settings)
                }
        .fullScreenCover(isPresented: $isShowingMap) {
            GeofencePickerView(selectedArea: $alarm.area)
        }
    }
}

struct AlarmSettingsView: View {
    @Binding var settings: AlarmSettings
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Restart after Notification")) {
                    Picker("Mode", selection: $settings.repeatMode) {
                        ForEach(RepeatMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
        }
    }
}

#Preview {
    
}
