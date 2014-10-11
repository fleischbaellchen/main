//
//  ViewController.swift
//  ReadBarcode
//
//  Created by David Keller on 10.10.14.
//  Copyright (c) 2014 fleischbaellchen. All rights reserved.
//

import UIKit

class ScanViewController: UIViewController {
    
    @IBOutlet var previewView: PreviewView!
    var _sessionManager: SessionManager?
    var stepTimer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self._sessionManager = SessionManager()
        if let sessionManager = _sessionManager {
            sessionManager.startRunning()
            self.previewView.session = sessionManager._captureSession!
        }
        self.stepTimer = NSTimer(timeInterval: 0.15, target: self, selector: "step", userInfo: nil, repeats: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Barcode Sequencer
    func step() {
        println("Step")
    }
    
}

