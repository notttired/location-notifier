//
//  MapReader.swift
//  location-notifier
//
//  Created by Max on 2026-02-02.
//

import SwiftUI
import MapKit

struct GeofencePickerView: View {
    @Binding var selectedArea: LocationArea
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            MapReader { proxy in
                Map(position: $position) {
                    if let location = selectedArea.location {
                        Marker("Target", coordinate: location)
                    }
                }
                .onTapGesture { screenPoint in
                    let coordinate = proxy.convert(screenPoint, from: .local)
                    if let coord = coordinate {
                        selectedArea.location = coord
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    var enterRegionSubscribers: [(CLRegion) -> Void] = []
    var lastLocation: CLLocation?
    private var activeGeofences: [LocationArea: String] = [:]
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        self.locationManager.requestAlwaysAuthorization()
    }
    
    func startTracking() {
        locationManager.startUpdatingLocation()
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.lastLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        for subscriber in enterRegionSubscribers {
            subscriber(region)
        }
    }
    
    func addGeofence(id: String, area: LocationArea) {
        guard let center = area.location else { return }
        let region = CLCircularRegion(
            center: center,
            radius: area.radius,
            identifier: id
        )
        
        region.notifyOnEntry = true
        
        locationManager.startMonitoring(for: region)
    }
    
    func removeGeofence(id: String) {
        for region in locationManager.monitoredRegions {
            if region.identifier == id {
                locationManager.stopMonitoring(for: region)
                print("Successfully removed geofence: \(id)")
            }
        }
    }
    
    func subscribe(callback: @escaping (CLRegion) -> Void) {
        enterRegionSubscribers.append(callback)
    }
    
    func syncGeofences(newGeofences : Set<LocationArea>) {
        let oldGeofences = Set(self.activeGeofences.keys)
        let toAdd = newGeofences.subtracting(oldGeofences)
        let toRemove = oldGeofences.subtracting(newGeofences)
        
        for geofence in toRemove {
            guard let id = self.activeGeofences[geofence] else { continue }
            _ = self.activeGeofences.removeValue(forKey: geofence)
            removeGeofence(id: id)
        }
        
        for geofence in toAdd {
            guard let id = UUID().uuidString as String? else { continue }
            self.activeGeofences[geofence] = id
            addGeofence(id: id, area: geofence)
        }
    }
}

