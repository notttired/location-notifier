//
//  MapView.swift
//  location-notifier
//
//  Created by Max on 2026-03-09.
//

import SwiftUI
import MapKit

struct SearchView: View {
    @Binding var fullSearchText: String
    @State private var partialSearchText = ""
    @State private var searchCompletionManager = SearchCompletionManager()
    @State private var showResults = true

    var filteredItems: [String] {
        let all = searchCompletionManager.results.map(\.item.title)
        return partialSearchText.isEmpty
            ? all
            : all.filter { $0.localizedCaseInsensitiveContains(partialSearchText) }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                    .font(.body)

                TextField("Search for places", text: $partialSearchText)
                    .textFieldStyle(.plain)
                    .submitLabel(.search)
                    .onSubmit {
                        searchCompletionManager.completeSearch(query: partialSearchText)
                        showResults = true
                    }

                if !partialSearchText.isEmpty {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            partialSearchText = ""
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .transition(.opacity.combined(with: .scale))
                }
            }
            .padding(10)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.horizontal)
            .padding(.vertical, 8)

            // MARK: - Results
            if showResults && !filteredItems.isEmpty {
                Divider()
                    .padding(.horizontal, 24)

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(filteredItems.enumerated()), id: \.element) { index, item in
                            Button {
                                fullSearchText = item
                                showResults = false
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "mappin.and.ellipse")
                                        .foregroundStyle(.red)
                                        .font(.callout)
                                        .frame(width: 24)

                                    Text(item)
                                        .foregroundStyle(.primary)
                                        .font(.body)
                                        .lineLimit(1)

                                    Spacer()
                                }
                                .padding(.vertical, 11)
                                .padding(.horizontal, 16)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)

                            if index < filteredItems.count - 1 {
                                Divider()
                                    .padding(.leading, 52)
                            }
                        }
                    }
                }
                .frame(maxHeight: 250)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .padding(.horizontal)
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
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
            .overlay(alignment: .bottom) {
                VStack(spacing: 12) {
                    HStack {
                        Label("Radius", systemImage: "circle.dashed")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(selectedArea.radius, format: .number.precision(.fractionLength(0))) m")
                            .font(.subheadline.weight(.semibold))
                            .monospacedDigit()
                    }

                    Slider(
                        value: $selectedArea.radius,
                        in: 100...1000,
                        step: 10
                    ) {
                        Text("Radius")
                    } minimumValueLabel: {
                        Text("100")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    } maximumValueLabel: {
                        Text("1000")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .tint(.blue)
                }
                .padding(16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .padding(.horizontal)
            }
        }
    }
}
