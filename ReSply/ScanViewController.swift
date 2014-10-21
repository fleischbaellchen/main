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
    @IBOutlet var whiteScreen: UIView!
    
    var _sessionManager: SessionManager?
    var stepTimer: NSTimer?
    
    var delegate: ScanViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
        
        self.whiteScreen.layer.opacity = 0.0
        
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
        // hint that led to this solution:
        // http://stackoverflow.com/a/12937852/286611
        dispatch_async(dispatch_get_main_queue()) {
            self.flashScreen()
        }
        delegate.scanViewControllerScanned(barcode)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // flash screen
    // take from here: http://stackoverflow.com/a/12119733/286611
    func flashScreen() {
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        let animationValues = [0.8, 0.0]
        let animationTimes = [0.3, 1.0]
        let timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        let animationTimingFunctions = [timingFunction, timingFunction]
        opacityAnimation.values = animationValues
        opacityAnimation.keyTimes = animationTimes
        opacityAnimation.timingFunctions = animationTimingFunctions
        opacityAnimation.fillMode = kCAFillModeForwards
        opacityAnimation.removedOnCompletion = true
        opacityAnimation.duration = 0.4
        
        self.whiteScreen.layer.addAnimation(opacityAnimation, forKey: "animation")
    }
    
}

