//
//  PreviewView.swift
//  ReadBarcode
//
//  Created by Dave on 11.10.14.
//  Copyright (c) 2014 fleischbaellchen. All rights reserved.
//

import UIKit
import AVFoundation

class PreviewView: UIView {
    var session: AVCaptureSession {
        get {
            let temp = self.layer as AVCaptureVideoPreviewLayer
            return temp.session
        }
        set {
            let temp = self.layer as AVCaptureVideoPreviewLayer
            temp.session = newValue
        }
    }
    
    override class func layerClass() -> AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
}
