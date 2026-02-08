//
//  User.swift
//  location-notifier
//
//  Created by Max on 2026-01-31.
//

struct User: Codable, Identifiable {
    let id: String
    var username: String
    var longitude: Double
    var latitude: Double
}
