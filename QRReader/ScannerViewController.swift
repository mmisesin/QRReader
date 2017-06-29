//
//  ViewController.swift
//  QRReader
//
//  Created by Artem Misesin on 5/4/17.
//  Copyright © 2017 Artem Misesin. All rights reserved.
//

import UIKit
import AVFoundation

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var previousButton: UIBarButtonItem!
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var qrMetadata: String = ""{
        didSet{
            previousButton.isEnabled = true
            performSegue(withIdentifier: "toInfo", sender: nil)
        }
    }
    //var messageLabel:UILabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.previousButton.tintColor = Colors.deleteColor
        
        previousButton.isEnabled = false
        navigationController?.navigationBar.barTintColor = Colors.barColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        self.navigationItem.title = "Scanning the QR-code"
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession = AVCaptureSession()
            
            captureSession?.addInput(input)
            
        } catch {
            print(error)
            return
        }
        
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.frame = self.view.bounds
        self.view.layer.addSublayer(videoPreviewLayer!)
        
        //captureSession?.startRunning()
        
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubview(toFront: qrCodeFrameView)
        }
        
        //self.view.bringSubview(toFront: messageLabel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        qrCodeFrameView?.frame = CGRect.zero
        captureSession?.startRunning()
    }

    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObjectTypeQRCode {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                qrMetadata = metadataObj.stringValue
                print(qrMetadata)
                captureSession?.stopRunning()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toInfo" {
            if let destination = segue.destination as? InfoViewController{
                destination.qrMetadata = self.qrMetadata
            }
        }
    }
    
}

