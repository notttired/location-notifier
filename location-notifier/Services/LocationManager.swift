//
//  MapReader.swift
//  location-notifier
//
//  Created by Max on 2026-02-02.
//

import SwiftUI
import MapKit

@Observable
class SearchManager {
    var results: [SearchableMapItem] = []
    
    func search(query: String, region: MKCoordinateRegion) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = query
        searchRequest.region = region
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response: MKLocalSearch.Response?, error: Error?) in
            guard let response = response else {
                let message = (error as NSError?)?.localizedDescription ?? "Unknown"
                print("Search failed: \(message)")
                return
            }
            self.results = response.mapItems.map{ result in
                SearchableMapItem(item: result)
            }
        }
    }
}

@Observable
class SearchCompletionManager: NSObject, MKLocalSearchCompleterDelegate {
    let searchCompleter = MKLocalSearchCompleter()
    var results: [SearchableCompletionItem] = []
    
    override init() {
        super.init()
        self.searchCompleter.delegate = self
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        print("Got search results")
        self.results = completer.results.map { item in
            SearchableCompletionItem(item: item)
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
    
    func completeSearch(query: String) {
        print("Starting search")
        self.searchCompleter.queryFragment = query
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
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
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
    
    func notifySubscribers(region: CLRegion) {
        for subscriber in enterRegionSubscribers {
            subscriber(region)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        self.notifySubscribers(region: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        switch state {
        case .inside:
            print("User is currently inside the area.")
            self.notifySubscribers(region: region)
        case .outside:
            print("User is outside the area.")
        case .unknown:
            print("Location signal too weak to determine state.")
        }
    }
    
    func addGeofence(id: String, area: LocationArea) {
        guard let center = area.center else { return }
        let region = CLCircularRegion(
            center: center,
            radius: area.radius,
            identifier: id
        )
        
        region.notifyOnEntry = true
        region.notifyOnExit = true
        
        locationManager.startMonitoring(for: region)
        locationManager.requestState(for: region)
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
