//
//  Instrument.swift
//  AudioKit-Sampler
//
//  Created by Mark Jeschke on 4/14/17.
//  Copyright © 2017 Mark Jeschke. All rights reserved.
//

import Foundation
import AudioKit

class Instrument: AKSampler {
    var name:String
    var filePath:String
    var reverbEnabled: Bool
    var delayEnabled: Bool
    var pitch: Double
    init(name:String,
         filePath:String,
         reverbEnabled: Bool,
         delayEnabled: Bool,
         pitch: Double) {
        self.name = name
        self.filePath = filePath
        self.reverbEnabled = reverbEnabled
        self.delayEnabled = delayEnabled
        self.pitch = pitch
    }
}
