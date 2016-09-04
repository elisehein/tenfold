//
//  SoundService.swift
//  Tenfold
//
//  Created by Elise Hein on 27/08/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import UIKit
import AVFoundation

enum Sound {
    case CrossOut
    case CrossOutRow
    case NextRound
}

class SoundService {
    static var singleton: SoundService? = nil

    var players: [Sound: AVAudioPlayer?] = [:]

    init() {
        players[.CrossOut] = SoundService.player(.CrossOut)
        players[.CrossOutRow] = SoundService.player(.CrossOutRow)
        players[.NextRound] = SoundService.player(.NextRound)
    }

    class func player(sound: Sound) -> AVAudioPlayer? {
        let sound = NSDataAsset(name: SoundService.assetName(sound))
        var player: AVAudioPlayer? = nil

        guard sound != nil else { return nil }

        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(data: sound!.data, fileTypeHint: AVFileTypeWAVE)
            player!.prepareToPlay()
        } catch {
            print("Error initializing AVAudioPlayer")
        }

        return player
    }

    class func assetName(sound: Sound) -> String {
        switch sound {
        case .CrossOut:
            return "crossOut"
        case .CrossOutRow:
            return "crossOutRow"
        case .NextRound:
            return "nextRound"
        }
    }

    func playIfAllowed(sound: Sound) {
        if StorageService.currentSoundPreference() == true {
            (players[sound]!)!.play()
        }
    }
}
