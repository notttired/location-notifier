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

struct SearchView: View {
    @Binding var fullSearchText: String
    @State private var partialSearchText = ""
    @State private var searchCompletionManager = SearchCompletionManager()
    @State private var showResults = true
    
    // Compute results dynamically to ensure UI stays in sync
    var filteredItems: [String] {
        let all = searchCompletionManager.results.map(\.item.title)
        return partialSearchText.isEmpty ? all : all.filter { $0.localizedCaseInsensitiveContains(partialSearchText) }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search for places", text: $partialSearchText)
                    .textFieldStyle(.plain)
                if !partialSearchText.isEmpty {
                    Button(action: { partialSearchText = "" }) {
                        Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                    }
                }
                Button(action: {
                    searchCompletionManager.completeSearch(query: partialSearchText)
                    self.showResults = true
                }) {
                    Image(systemName: "magnifyingglass").foregroundColor(.gray)
                }
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding()


            if self.showResults {
                List(filteredItems, id: \.self) { item in
                    Text(item).onTapGesture {
                        self.fullSearchText = item
                        self.showResults = false
                    }
                }
                .listStyle(.plain)
                .frame(maxHeight: 250)
            }
        }
    }
}

struct GeofencePickerView: View {
    @Binding var selectedArea: LocationArea
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedItem: MKMapItem?
    @State private var searchText = ""
    @State private var searchManager = SearchManager()
    @Environment(LocationManager.self) private var locationManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                MapReader { proxy in
                    Map(position: $position, selection: $selectedItem) {
                        UserAnnotation()
                        if let location = selectedArea.center {
                            Marker("Target", coordinate: location)
                            MapCircle(center: location, radius: selectedArea.radius)
                                .foregroundStyle(.blue.opacity(0.3))
                                .stroke(.blue, lineWidth: 2)
                        }
                        ForEach(searchManager.results) { result in
                            Marker(item: result.item)
                        }
                    }
                    .onTapGesture { screenPoint in
                        let coordinate = proxy.convert(screenPoint, from: .local)
                        if let coord = coordinate {
                            selectedArea.center = coord
                        }
                    }
                    .safeAreaInset(edge: .top) {
                        SearchView(fullSearchText: $searchText)
                    }
                }
                .onChange(of: searchText) { oldText, newText in
                    if newText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return }

                    let center: CLLocationCoordinate2D
                    if let areaCenter = self.selectedArea.center {
                        center = areaCenter
                    } else if let areaCenter = locationManager.lastLocation {
                        center = areaCenter.coordinate
                    } else {
                        return
                    }

                    let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    let region = MKCoordinateRegion(center: center, span: span)
                    searchManager.search(query: newText, region: region)
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack {
                    Text("Radius: \(selectedArea.radius, format: .number.precision(.fractionLength(0))) m")
                    Slider(
                        value: $selectedArea.radius,
                        in: 100...1000,
                        step: 10
                    ) {
                        Text("Radius")
                    } minimumValueLabel: {
                        Text("100")
                    } maximumValueLabel: {
                        Text("1000")
                    }
                }
                .padding(20)
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

#Preview {
    SearchView(fullSearchText: .constant(""))
}
