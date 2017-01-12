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
    case crossOut
    case crossOutRow
    case nextRound
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

        players[.crossOut] = SoundService.player(.crossOut)
        players[.crossOutRow] = SoundService.player(.crossOutRow)
        players[.nextRound] = SoundService.player(.nextRound)
    }

    class func player(_ sound: Sound) -> AVAudioPlayer? {
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

    class func assetName(_ sound: Sound) -> String {
        switch sound {
        case .crossOut:
            return "crossOut"
        case .crossOutRow:
            return "crossOutRow"
        case .nextRound:
            return "nextRound"
        }
    }

    func playIfAllowed(_ sound: Sound) {
        if StorageService.currentFlag(forSetting: .SoundOn) {
            (players[sound]!)!.play()
        }
    }

    func vibrateIfAllowed(_ sound: Sound) {
        guard forceTouchVibrationsAvailable() else { return }

        if StorageService.currentFlag(forSetting: .VibrationOn) {
            if sound == .crossOut {
                AudioServicesPlaySystemSound(1519)
            } else {
                AudioServicesPlaySystemSound(1521)
            }
        }
    }

    func forceTouchVibrationsAvailable() -> Bool {
        // swiftlint:disable line_length
        return UIDevice.current.userInterfaceIdiom != .pad &&
               UIApplication.shared.keyWindow?.rootViewController?.traitCollection.forceTouchCapability == .available
    }
}
