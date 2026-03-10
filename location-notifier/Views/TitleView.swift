//
//  TitleView.swift
//  location-notifier
//
//  Created by Max on 2026-03-08.
//

import SwiftUI


struct TitleView: View {
    var body: some View {
        Text("Location Notifier")
            .font(.largeTitle)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
    }
}

#Preview {
    TitleView()
}
