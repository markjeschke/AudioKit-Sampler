//
//  ViewController.swift
//  AudioKit-Sampler
//
//  Created by Mark Jeschke on 4/10/17.
//  Copyright © 2017 Mark Jeschke. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // Instantiate AudioKit engine
    var conductor = Conductor.sharedInstance
    var mainCGColor: CGColor = UIColor(red:10/255, green:96/255, blue:255/255, alpha:1.0).cgColor
    var mainColor: UIColor = UIColor(red:10/255, green:96/255, blue:255/255, alpha:1.0)
    
    @IBOutlet weak var outputText: UILabel!
    @IBOutlet weak var midiLearnButton: UIButton!
    @IBOutlet weak var kickButton: UIButton!
    @IBOutlet weak var snareButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add Notification observer to send output message from the Conductor audio instance to the UILabel in this ViewController
        let nc = NotificationCenter.default
        nc.addObserver(forName:NSNotification.Name(rawValue: "outputMessage"), object:nil, queue:nil, using:catchNotification)
        
    }
    
    func catchNotification(notification:Notification) -> Void {
        guard let userInfo = notification.userInfo,
            let message  = userInfo["message"] as? String else {
                print("No userInfo found in notification")
                return
        }
        DispatchQueue.main.async(execute: {
            self.outputText.text = message
        })
    }
    
    // MARK: IBActions
    
    @IBAction func toggleMidiLearn(_ sender: UIButton) {
        conductor.toggleMidiLearn()
        if conductor.midiLearnEnabled {
            midiLearnButton.isSelected = true
            
            // Update UI
            kickButton.layer.borderColor = mainCGColor
            kickButton.layer.borderWidth = 1.0
            kickButton.titleLabel?.textColor = mainColor
            snareButton.layer.borderColor = mainCGColor
            snareButton.layer.borderWidth = 1.0
            snareButton.titleLabel?.textColor = mainColor
        } else {
            midiLearnButton.isSelected = false
            
            // Update UI
            kickButton.layer.borderColor = UIColor.clear.cgColor
            kickButton.layer.borderWidth = 0.0
            kickButton.setTitleColor(mainColor, for: .normal)
            kickButton.backgroundColor = UIColor.clear
            snareButton.layer.borderColor = UIColor.clear.cgColor
            snareButton.layer.borderWidth = 0.0
            snareButton.setTitleColor(mainColor, for: .normal)
            snareButton.backgroundColor = UIColor.clear
        }
    }
    
    @IBAction func triggerKick() {
        if conductor.midiLearnEnabled {
            conductor.currentInstrument = "kick"
            conductor.setMidiEventUpdate()
            
            // Update UI
            kickButton.setTitleColor(UIColor.white, for: .normal)
            kickButton.backgroundColor = mainColor
            kickButton.titleLabel?.textColor = UIColor.white
            snareButton.setTitleColor(mainColor, for: .normal)
            snareButton.titleLabel?.textColor = mainColor
            snareButton.backgroundColor = UIColor.clear
        } else {
            conductor.playKick()
        }
    }
    
    @IBAction func triggerSnare() {
        if conductor.midiLearnEnabled {
            conductor.currentInstrument = "snare"
            conductor.setMidiEventUpdate()
            
            // Update UI
            snareButton.setTitleColor(UIColor.white, for: .normal)
            snareButton.backgroundColor = mainColor
            snareButton.titleLabel?.textColor = UIColor.white
            kickButton.setTitleColor(mainColor, for: .normal)
            kickButton.titleLabel?.textColor = mainColor
            kickButton.backgroundColor = UIColor.clear
        } else {
             conductor.playSnare()
        }
    }
    
    @IBAction func toggleOscillator(sender: UIButton) {
        conductor.playOscillator()
        if conductor.oscillator.isPlaying {
            sender.setTitle("Play Sine Wave", for: .normal)
        } else {
            sender.setTitle("Stop Sine Wave at \(Int(conductor.oscillator.frequency))Hz", for: .normal)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
         name: NSNotification.Name(rawValue: "outputMessage"),
         object: nil)
    }
    
}
