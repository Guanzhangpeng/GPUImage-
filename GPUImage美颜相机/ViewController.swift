//
//  ViewController.swift
//  GPUImage美颜相机
//
//  Created by 管章鹏 on 2017/11/28.
//  Copyright © 2017年 管章鹏. All rights reserved.
//

import UIKit
import GPUImage

class ViewController: UIViewController {
    
    @IBOutlet var imageView : UIImageView!
    
    fileprivate lazy var camera : GPUImageStillCamera = GPUImageStillCamera(sessionPreset: AVCaptureSession.Preset.high.rawValue, cameraPosition: .front)
    fileprivate lazy var filter = GPUImageBrightnessFilter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1.设置相机方向
        camera.outputImageOrientation = .portrait
        
        // 2.创建美白/曝光 滤镜的值
        filter.brightness = 0.6
        camera.addTarget(filter)
        
        // 3.创建GPUImageView,用于显示实时画面
        let showView = GPUImageView(frame: view.bounds)
        view.insertSubview(showView, at: 0)
        filter.addTarget(showView)
        
        // 4.开始捕捉画面
        camera.startCapture()
    }
    
    @IBAction func takePhoto() {
        camera.capturePhotoAsImageProcessedUp(toFilter: filter, withCompletionHandler: { (image, error) in
            
            UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
            self.imageView.image = image
            self.camera.stopCapture()
        })
    }
}

