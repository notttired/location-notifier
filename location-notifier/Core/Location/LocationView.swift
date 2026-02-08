//
//  LocationManager.swift
//  location-notifier
//
//  Created by Max on 2026-01-31.
//

import SwiftUI
import CoreLocation
import MapKit

@Observable
@MainActor
class LocationViewModel: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    var lastLocation: CLLocation?
    var isFollowing = false
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        self.locationManager.requestAlwaysAuthorization()
    }
    
    func startTracking() {
        isFollowing = true
        locationManager.startUpdatingLocation()
        print("Started")
    }
    
    func stopTracking() {
        isFollowing = false
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Got location")
        self.lastLocation = locations.last
    }
}

struct LocationView: View {
    @State private var viewModel = LocationViewModel()
    
    var body: some View {
        VStack(spacing: 10) {
            if let location = viewModel.lastLocation {
                VStack {
                    Text("Current Coordiantes")
                    Text("\(location.coordinate.latitude), \(location.coordinate.longitude)")
                }
            } else {
                Text("Location unknown")
            }
            
            Button (viewModel.isFollowing ? "Stop Tracking" : "Start Tracking") {
                if viewModel.isFollowing {
                    viewModel.stopTracking()
                } else {
                    viewModel.startTracking()
                }
            }
        }
    }
}

struct InteractiveMapView: View {
    @State private var viewModel = LocationViewModel()
    
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    
    var body: some View {
        Map(position: $cameraPosition) {
            if let location = viewModel.lastLocation {
                Marker("You are here", coordinate: location.coordinate)
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapPitchToggle()
        }
        .onAppear {
            viewModel.startTracking()
        }
        .onChange(of: viewModel.lastLocation) { oldLocation, newLocation in
            if let newLocation {
                withAnimation {
                    cameraPosition = .region(
                        MKCoordinateRegion(
                            center: newLocation.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )
                    )
                }
            }
        }
    }
}
