//
//  ContentView.swift
//  location-notifier
//
//  Created by Max on 2026-01-31.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

struct ProfileHeader: View {
    // 1. The State (The Source of Truth)
    @State private var isFollowing = false
    
    var body: some View {
        // 2. The Layout
        VStack(spacing: 20) {
            Image("avatar")
                .resizable()
                .frame(width: 80, height: 80)
                .clipShape(Circle()) // 3. Styling (Modifiers)
            
            Text("Alex Nomad")
                .font(.headline)
            
            Button(isFollowing ? "Unfollow" : "Follow") {
                // 4. The Action (Changes State, which triggers a Re-render)
                isFollowing.toggle()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    ProfileHeader()
}
