//
//  ViewController.swift
//  testCamera
//
//  Created by pi2018 on 18/04/2018.
//  Copyright © 2018 pi2018. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var camera : BenchCamera?
    
    @IBOutlet weak var viewImage: UIImageView!
    
    override func viewDidLoad() {
        camera = BenchCamera()
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func takePic(_ sender: Any) {
        camera?.capturePhoto()
        //delay(bySeconds: 0.5, dispatchLevel: .main) {
            // delayed code that will run on main thread
            // We need to wait the end of the thread th
            //self.viewImage.image = self.camera?.getImageCaptured()
        //}
        DispatchQueue.global(qos: .background).async {
              self.camera?.getImageCaptured()
        }
    }
    
    @IBAction func affichageButton(_ sender: Any) {
        viewImage.image = camera?.getImageCaptured()
    }
    
    public func delay(bySeconds seconds: Double, dispatchLevel: DispatchLevel = .main, closure: @escaping () -> Void) {
        let dispatchTime = DispatchTime.now() + seconds
        dispatchLevel.dispatchQueue.asyncAfter(deadline: dispatchTime, execute: closure)
    }
    
    public enum DispatchLevel {
        case main, userInteractive, userInitiated, utility, background
        var dispatchQueue: DispatchQueue {
            switch self {
            case .main:                 return DispatchQueue.main
            case .userInteractive:      return DispatchQueue.global(qos: .userInteractive)
            case .userInitiated:        return DispatchQueue.global(qos: .userInitiated)
            case .utility:              return DispatchQueue.global(qos: .utility)
            case .background:           return DispatchQueue.global(qos: .background)
            }
        }
    }
}

