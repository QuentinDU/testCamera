//
//  BenchCamera.swift
//  camera
//
//  Created by pi2018 on 13/04/2018.
//  Copyright © 2018 pi2018. All rights reserved.
//

import UIKit
import AVFoundation


class BenchCamera : NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate {
    
    // MARK : Attribute
    var captureSession: AVCaptureSession?
    var photoCapture: AVCapturePhotoOutput?
    var photoSettings: AVCapturePhotoSettings?
    var captureDevice: AVCaptureDevice?
    // The photo will be stored in imageCaptured. Get the picture by using the func getImageCaptured.
    var imageCaptured: UIImage?
    // We add a semaphore (initialized with only one token) to make sure that the picture was taken and can be returned
    let semaphore = DispatchSemaphore(value: 1)
    
    // value for the parameter
    var second: Int? {
        get {
            return self.second
        }
        set(nouvSecond) {
            self.second = nouvSecond
        }
    }
    var newIso: Float? {
        get {
            return self.newIso
        }
        set(nouvIso) {
            self.newIso = nouvIso
        }
    }
    var preferredTimeScale: Int32? {
        get {
            return self.preferredTimeScale
        }
        set(newPreferredTimeScale) {
            self.preferredTimeScale = newPreferredTimeScale
        }
    }
    var ExposureTime: CMTime? {
        get {
            return self.ExposureTime
        }
        set(newExposureTime) {
            self.ExposureTime = newExposureTime
        }
    }
    
    override init() {
        captureDevice = AVCaptureDevice.default(for : AVMediaType.video)
        
        // Verification of the value of minISO and MaxIso
        print(captureDevice?.activeFormat.minISO as Any)
        print(captureDevice?.activeFormat.maxISO as Any)
        
        // Settings of the exposure Time of the device
        let second = 1
        let newIso = Float(50) //Float(400) // ISO sensibilité du capteur
        let preferredTimeScale = Int32(600) //Int32(600)
        let ExposureTime : CMTime = CMTimeMake(Int64(second), preferredTimeScale)
        
        do {
            try captureDevice?.lockForConfiguration()
            //print("\(String(describing: test))") // dunno what i wanted to know
            
            captureDevice?.exposureMode = .custom
            captureDevice?.setExposureModeCustom(duration: ExposureTime, iso: newIso, completionHandler: nil)
            }
        catch {
            print(error)
        }
        
        do {
            // MARK : Setup of the Camera
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            
            // Open the session to take picture
            photoCapture = AVCapturePhotoOutput()
            if (captureSession?.canAddOutput(photoCapture!))! {
                photoCapture?.isHighResolutionCaptureEnabled = true
                photoCapture?.isLivePhotoCaptureEnabled = (photoCapture?.isLivePhotoCaptureSupported)!
                
                captureSession?.addOutput(photoCapture!)
            } else {
                print("Could not add photo output to the session")
            }
            
            // MARK : Configuration of the camera
            // We use the most recommended and simplest preset : enables maximum preset and exposure duration ranges, phase detection autof
            captureSession?.sessionPreset = AVCaptureSession.Preset.photo
            
            // MARK : Launch of the camera
            captureSession?.startRunning()
        } catch {
            print(error)
        }
        
        guard let connection = photoCapture?.connection(with: AVMediaType.video) else {
            super.init()
            return }
        connection.videoOrientation = .portrait
        imageCaptured = nil
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func closeSession() {
        // We stop the session of the camera
        if (captureSession?.isRunning)! {
            captureSession?.stopRunning()
            captureDevice?.unlockForConfiguration()
        }
    }

    // Capture only take a picture and store it in the image library
    func capturePhoto() { //-> UIImage {
        /// This function allow you to get a picture of your session that you previously open.
    
        // MARK : Setting of the camera
        photoSettings = AVCapturePhotoSettings()
        photoSettings?.flashMode = .off //.off pour les tests, on met le flash
        photoSettings?.isHighResolutionPhotoEnabled = true
        photoSettings?.isAutoStillImageStabilizationEnabled = true
    
        // We wait that the previous photo was taken
        print("wait semaphore : capturePhoto")
        semaphore.wait()
        print("semaphore taken : capturePhoto")
        // to take a picture :
        let date = Date()
        print("\(date) : Beginning of the process of taking a picture")
        photoCapture?.capturePhoto(with: photoSettings!, delegate: self)
    }

    func getImageCaptured() -> UIImage {
        print("wait semaphore : getImageCaptured")
        semaphore.wait()
        print("semaphore taken : getImageCaptured")
        semaphore.signal()
        return imageCaptured!
        
    }
    
    func actualiseExposureModeCustom() {
        captureDevice?.setExposureModeCustom(duration: ExposureTime!, iso: newIso!, completionHandler: nil)
    }
    
    // MARK : Function use by delegate
    func photoOutput(_ captureOutput: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?,
                     previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
                     resolvedSettings: AVCaptureResolvedPhotoSettings,
                     bracketSettings: AVCaptureBracketedStillImageSettings?,
                     error: Error?) {
        // get captured image
        
        // Check the photo buffer
        guard error == nil,
            let photoSampleBuffer = photoSampleBuffer else {
                print ("Error capturing photo: \(String(describing: error))")
                return
        }
        
        // Convert the buffer to have a jpeg image by using AVCapturePhotoOutput
        guard let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer : photoSampleBuffer, previewPhotoSampleBuffer : previewPhotoSampleBuffer) else {
            return
        }
        
        // Initialise a UIImage with our image imageData
        // this part allows us to choose the destination of the picture that we took.
        // In this case, we will send the picture in photos album
        let capturedImage = UIImage.init(data : imageData, scale : 1.0)
        
        if let image = capturedImage {
            imageCaptured = image.copy() as? UIImage
            let date = Date()
            print("\(date) : Photo taken : The photo has been attribute to imageCaptured")
            semaphore.signal()
            print("release semaphore / photo was taken")
        }
    }
}




