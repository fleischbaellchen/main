//
//  SessionManager.swift
//  ReadBarcode
//
//  Created by Dave on 11.10.14.
//  Copyright (c) 2014 fleischbaellchen. All rights reserved.
//

import Foundation
import AVFoundation

class SessionManager: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    
    var barcodes: [AnyObject]?
    
    var metadataOutput: AVCaptureMetadataOutput!
    
    var _captureSession: AVCaptureSession?
    private var _videoDevice: AVCaptureDevice!
    private var _videoInput: AVCaptureDeviceInput!
    private var _sessionQueue: dispatch_queue_t
    var _running: Bool
    
    override init() {
        _sessionQueue = dispatch_queue_create("ch.zkdk.ReadBarcode.caputre", DISPATCH_QUEUE_SERIAL)
        _running = false
    }
    
    func startRunning() {
        dispatch_sync(_sessionQueue) {
            self.setupCaptureSession()
            
            self._captureSession?.startRunning()
            self._running = true
            
            self.metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeEAN13Code]
        }
    }
    
    func stopRunning() {
        dispatch_sync(_sessionQueue) {
            self._running = false
            
            self._captureSession?.stopRunning()
            self._captureSession = nil
        }
    }
    
    func setupCaptureSession() {
        
        if _captureSession != nil {
            return
        }
        
        _captureSession = AVCaptureSession()
        
        if let captureSession = _captureSession {
            _videoDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
            _videoInput = AVCaptureDeviceInput(device: _videoDevice, error: nil)
            if (captureSession.canAddInput(_videoInput)) {
                captureSession.addInput(_videoInput)
            }
            
            self.metadataOutput = AVCaptureMetadataOutput()
            let metadataQueue = dispatch_queue_create("ch.zkdk.ReadBarcode.metadata", nil)
            self.metadataOutput.setMetadataObjectsDelegate(self, queue: metadataQueue)
            
            if (captureSession.canAddOutput(self.metadataOutput)) {
                captureSession.addOutput(self.metadataOutput)
            }
        }
    }
    
    
    
    //MARK: Metadata output delegate
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        let barcodes = metadataObjects as [AVMetadataMachineReadableCodeObject]
        println("callback for output \(barcodes[0].stringValue)")
    }
}

