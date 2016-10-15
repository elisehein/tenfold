//
//  SoundService.swift
//  Tenfold
//
//  Created by Elise Hein on 27/08/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

enum Sound {
    case CrossOut
    case CrossOutRow
    case NextRound
}

class SoundService {
    static var singleton: SoundService? = nil

    var players: [Sound: AVAudioPlayer?] = [:]

    init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error as NSError {
            print(error)
        }

        players[.CrossOut] = SoundService.player(.CrossOut)
        players[.CrossOutRow] = SoundService.player(.CrossOutRow)
        players[.NextRound] = SoundService.player(.NextRound)
    }

    class func player(sound: Sound) -> AVAudioPlayer? {
        let sound = NSDataAsset(name: SoundService.assetName(sound))
        var player: AVAudioPlayer? = nil

        guard sound != nil else { return nil }

        do {
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
        if StorageService.currentFlag(forSetting: .SoundOn) {
            (players[sound]!)!.play()
        }
    }

    func vibrateIfAllowed(sound: Sound) {
        guard forceTouchVibrationsAvailable() else { return }

        if StorageService.currentFlag(forSetting: .VibrationOn) {
            if sound == .CrossOut {
                AudioServicesPlaySystemSound(1519)
            } else {
                AudioServicesPlaySystemSound(1521)
            }
        }
    }

    func forceTouchVibrationsAvailable() -> Bool {
        // swiftlint:disable line_length
        return UIDevice.currentDevice().userInterfaceIdiom != .Pad &&
               UIApplication.sharedApplication().keyWindow?.rootViewController?.traitCollection.forceTouchCapability == .Available
    }
}
