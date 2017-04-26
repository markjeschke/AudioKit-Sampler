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
    
    @IBOutlet weak var outputText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
    
    @IBAction func triggerKick() {
        conductor.playKick()
    }
    
    @IBAction func triggerSnare() {
        conductor.playSnare()
    }
    
    @IBAction func toggleOscillator(sender: UIButton) {
        conductor.playOscillator()
        if conductor.oscillator.isPlaying {
            sender.setTitle("Play Sine Wave", for: .normal)
        } else {
            sender.setTitle("Stop Sine Wave at \(Int(conductor.oscillator.frequency))Hz", for: .normal)
        }
    }
    
}
