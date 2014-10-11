//
//  ViewController.swift
//  ReadBarcode
//
//  Created by David Keller on 10.10.14.
//  Copyright (c) 2014 fleischbaellchen. All rights reserved.
//

import UIKit

protocol ScanViewControllerDelegate {
    func scanViewControllerDidStopScanning(controller: ScanViewController)
    func scanViewControllerScanned(barcode: String)
}

class ScanViewController: UIViewController, SessionManagerDelegate {
    
    @IBOutlet var previewView: PreviewView!
    var _sessionManager: SessionManager?
    var stepTimer: NSTimer?
    
    var delegate: ScanViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
        
        
        self._sessionManager = SessionManager(delegate: self)
        if let sessionManager = _sessionManager {
            sessionManager.startRunning()
            self.previewView.session = sessionManager._captureSession!
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tappedFinish() {
        _sessionManager?.stopRunning()
        delegate.scanViewControllerDidStopScanning(self)
    }
    
    //MARK: - SessionManagerDelegate
    func scanned(barcode: String) {
        println("scanned barcode \(barcode)")
        delegate.scanViewControllerScanned(barcode)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    
}

