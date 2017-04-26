//
//  Conductor.swift
//  AudioKit-Sampler
//
//  Created by Mark Jeschke on 4/10/17.
//  Copyright © 2017 Mark Jeschke. All rights reserved.
//

import AudioKit

class Conductor: AKMIDIListener {
    
    static let sharedInstance = Conductor()
    
    // Set instance variables
    var kickSampler = AKMIDISampler()
    var snareSampler = AKMIDISampler()
    var oscillator = AKOscillator()
    var mixer = AKMixer()
    var delay: AKDelay!
    var delayMixer: AKDryWetMixer!
    var reverb: AKReverb!
    var reverbMixer: AKDryWetMixer!
    var booster: AKBooster!
    var globalMIDIChannel: UInt8
    var kickVolume: Double
    var kickPitch: MIDINoteNumber
    var kickPan: Double
    var snareVolume: Double
    var snarePitch: MIDINoteNumber
    var snarePan: Double
    let midi = AKMIDI()
    var outputMIDIMessage: String
    
    init() {
        
        do {
            try self.kickSampler.loadWav("Sounds/min_kick_02_C")
            try self.snareSampler.loadWav("Sounds/Ensoniq-ESQ-1-Snare")
        } catch {
            print("Could not locate the wav files.")
        }
        
        // Combine the kick and snare drum samples with the oscillator output into a mixer.
        mixer = AKMixer(kickSampler, snareSampler, oscillator)
        
        // Connect the mixer output to the delay node.
        delay = AKDelay(mixer)
        delay.time = 1.0 // seconds
        delay.feedback  = 0.1 // Normalized Value 0 - 1
        delay.dryWetMix = 0.0  // Normalized Value 0 - 1
        delay.lowPassCutoff = 15000
        
        // Connect the mixer output and the delay effect to its own delayMixer.
        // mixer output 0 << 0.5 >> 1.0 delay effect
        delayMixer = AKDryWetMixer(mixer, delay)
        delayMixer.balance = 0.8
        
        // Connect the delayMixer output to the reverb node.
        reverb = AKReverb(delayMixer)
        reverb.dryWetMix = 0.3
        reverb.loadFactoryPreset(.largeRoom)
        
        // Connect the mixer output and the reverb effect to its own reverbMixer.
        // mixer output 0 << 0.5 >> 1.0 reverb effect
        reverbMixer = AKDryWetMixer(delayMixer, reverb)
        reverbMixer.balance = 0.8
        
        // Connect the reverbMixer output to the booster node.
        booster = AKBooster(reverbMixer)
        booster.gain = 1.0
        
        globalMIDIChannel = 1
        
        kickPan = 0.0
        kickPitch = 60
        kickVolume = 1.0
        kickSampler.pan = kickPan
        kickSampler.volume = kickVolume
        
        snarePan = 0.0
        snarePitch = 60
        snareVolume = 1.0
        snareSampler.pan = snarePan
        snareSampler.volume = snareVolume
        
        // Connect the end of the audio chain to the global output.
        AudioKit.output = booster
        
        // Start the audio engine
        AudioKit.start()
        print("Audio engine started")
        
        print("midi.inputNames: \(midi.inputNames)")
        outputMIDIMessage = String(describing: midi.inputNames)
        midi.openInput()
        midi.addListener(self)
        
    }
    
    func captureMIDIText() {
        let nc = NotificationCenter.default
        nc.post(name:NSNotification.Name(rawValue: "outputMessage"),
                object: nil,
                userInfo:["message":outputMIDIMessage])
    }
    
    // MARK: - AKMIDIListener protocol functions
    
    func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        if noteNumber == 36 || noteNumber == 48 {
            kickSampler.play(noteNumber: kickPitch, velocity: velocity, channel: channel)
        }
        if noteNumber == 38 || noteNumber == 50 {
            snareSampler.play(noteNumber: snarePitch, velocity: velocity, channel: channel)
        }
        outputMIDIMessage = "Channel: \(channel + 1) noteOn: \(noteNumber) velocity: \(velocity)"
        captureMIDIText()
    }
    
    func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        outputMIDIMessage = "Channel: \(channel + 1) noteOff: \(noteNumber) velocity: \(velocity)"
        captureMIDIText()
    }
    
    func receivedMIDIController(_ controller: MIDIByte, value: MIDIByte, channel: MIDIChannel) {
        outputMIDIMessage = "Channel: \(channel + 1) controller: \(controller) value: \(value)"
        captureMIDIText()
    }
    
    func receivedMIDIAftertouch(noteNumber: MIDINoteNumber,
                                pressure: MIDIByte,
                                channel: MIDIChannel) {
        outputMIDIMessage = "Channel: \(channel + 1) midiAftertouchOnNote: \(noteNumber) pressure: \(pressure)"
        captureMIDIText()
    }
    
    func receivedMIDIAfterTouch(_ pressure: MIDIByte, channel: MIDIChannel) {
        outputMIDIMessage = "Channel: \(channel + 1) midiAfterTouch pressure: \(pressure)"
        captureMIDIText()
    }
    
    func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIByte, channel: MIDIChannel) {
        outputMIDIMessage = "Channel: \(channel + 1)  midiPitchWheel: \(pitchWheelValue)"
        captureMIDIText()
    }
    
    func receivedMIDIProgramChange(_ program: MIDIByte, channel: MIDIChannel) {
        if program == 5 {
            kickSampler.play(noteNumber: kickPitch, velocity: 80, channel: channel)
        }
        if program == 1 {
            snareSampler.play(noteNumber: snarePitch, velocity: 80, channel: channel)
        }
        outputMIDIMessage = "Channel: \(channel + 1) programChange: \(program)"
        captureMIDIText()
    }
    
    func receivedMIDISystemCommand(_ data: [MIDIByte]) {
        if let command = AKMIDISystemCommand(rawValue: data[0]) {
            var newString = "MIDI System Command: \(command) \n"
            for i in 0 ..< data.count {
                newString.append("\(data[i]) ")
            }
            outputMIDIMessage = newString
            captureMIDIText()
        }
    }
    
    public func playKick() {
        kickSampler.play(noteNumber:60,velocity:80,channel:1)
        outputMIDIMessage = "kick was triggered"
        captureMIDIText()
    }
    
    public func playSnare() {
        snareSampler.play(noteNumber:60,velocity:80,channel:1)
        outputMIDIMessage = "snare was triggered"
        captureMIDIText()
    }
    
    public func playOscillator() {
        if oscillator.isPlaying {
            oscillator.stop()
        } else {
            oscillator.amplitude = random(0.5, 1)
            oscillator.frequency = random(220, 880)
            oscillator.start()
        }
        outputMIDIMessage = "oscillator was triggered"
        captureMIDIText()
    }
}
