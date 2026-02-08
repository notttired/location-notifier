//
//  TestView.swift
//  location-notifier
//
//  Created by Max on 2026-02-05.
//

import SwiftUI

struct TestView: View {
    @Environment(AlarmManager.self) var alarmManager
    var body: some View {
        Button {
            alarmManager.play_alarm()
        } label : {
            Text("Test")
        }
    }
}
