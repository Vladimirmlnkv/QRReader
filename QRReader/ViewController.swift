//
//  ViewController.swift
//  QRReader
//
//  Created by Владимир Мельников on 27/01/2017.
//  Copyright © 2017 Владимир Мельников. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    var qrCodeFrameView: UIView!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var captureSession: AVCaptureSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        captureSession.startRunning()
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
            
            let metaDataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(metaDataOutput)
            metaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metaDataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)!
            previewLayer.bounds = view.bounds
            previewLayer.position = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            let cameraPreview = UIView(frame: CGRect(x: 0.0, y: 0.0, width: view.bounds.size.width, height: view.bounds.size.height))
            cameraPreview.layer.addSublayer(previewLayer)
            view.addSubview(cameraPreview)
            
        } catch (let error) {
            print(error.localizedDescription)
        }
        
        qrCodeFrameView = UIView()
        qrCodeFrameView.layer.borderColor = UIColor.red.cgColor
        qrCodeFrameView.layer.borderWidth = 2
        view.addSubview(qrCodeFrameView!)
        view.bringSubview(toFront: qrCodeFrameView!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession.startRunning()
    }
    
    func willEnterForeground() {
        captureSession.startRunning()
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.isEmpty {
            qrCodeFrameView?.frame = CGRect.zero
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObjectTypeQRCode {
            captureSession.stopRunning()
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            let barCodeObject = previewLayer.transformedMetadataObject(for: metadataObj) as! AVMetadataMachineReadableCodeObject
            qrCodeFrameView?.frame = barCodeObject.bounds
            
            if let url = URL(string: barCodeObject.stringValue) {
                UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                    self.qrCodeFrameView?.frame = CGRect.zero
                })
            } else {
                let vc = storyboard?.instantiateViewController(withIdentifier: "MessageViewController") as! MessageViewController
                vc.text = barCodeObject.stringValue
                let navVC = UINavigationController(rootViewController: vc)
                present(navVC, animated: true, completion: {
                    self.qrCodeFrameView?.frame = CGRect.zero
                })
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

