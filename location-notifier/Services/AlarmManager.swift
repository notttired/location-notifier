//
//  AlarmService.swift
//  location-notifier
//
//  Created by Max on 2026-02-04.
//

import AVFoundation
import AudioToolbox


@Observable
class AlarmManager {
    var audioPlayer: AVAudioPlayer?
    
    func play_alarm() {
        let audioSession = AVAudioSession.sharedInstance()
        configureAudioSession(audioSession: audioSession)
        
        do {
            try audioSession.setActive(true)
            
            guard let url = Bundle.main.url(forResource: "alarm", withExtension: "wav") else {
                return
            }
            
            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            self.audioPlayer = audioPlayer
            
            audioPlayer.numberOfLoops = 0
            audioPlayer.volume = 1.0
            audioPlayer.play()
            
        } catch {
            print("Error playing notification")
        }
    }
    
    func stop_alarm() {
        self.audioPlayer?.stop()
    }
}

func configureAudioSession(audioSession: AVAudioSession) {
    do {
        try audioSession.setCategory(
            AVAudioSession.Category.playback,
            mode: AVAudioSession.Mode.default,
            options: [
                AVAudioSession.CategoryOptions.duckOthers,
            ]
        )
    } catch {
        print("Error setting up audioSession \(error)")
    }
}
