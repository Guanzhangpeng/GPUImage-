//
//  ViewController.swift
//  GPUImage中的几种滤镜效果
//
//  Created by 管章鹏 on 2017/11/27.
//  Copyright © 2017年 管章鹏. All rights reserved.
//

import UIKit
import GPUImage
class ViewController: UIViewController {
    
    @IBOutlet weak var sourceImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}
// MARK:- 点击事件
extension ViewController
{
    // MARK:- 高斯模糊效果
    @IBAction func GaoSi(_ sender: Any) {
        let filter = GPUImageGaussianBlurFilter()
        filter.texelSpacingMultiplier = 2
        filter.blurRadiusInPixels = 5
        sourceImage.image = processImgWithFilter(filter)
    }
    
    // MARK:- 卡通效果
    @IBAction func Katong(_ sender: Any) {
        
        let filter = GPUImageToonFilter()
        sourceImage.image = processImgWithFilter(filter)
    }
    
    // MARK:- 褐色效果
    @IBAction func Hese(_ sender: Any) {
        let filter = GPUImageSepiaFilter()
        sourceImage.image = processImgWithFilter(filter)
    }
    
    // MARK:- 雕刻效果
    @IBAction func DiaoKe(_ sender: Any) {
        let filter = GPUImageEmbossFilter()
        sourceImage.image = processImgWithFilter(filter)
    }
    
    // MARK:- 素描效果
    @IBAction func Sumiao(_ sender: Any) {
        let filter = GPUImageSketchFilter()
        sourceImage.image = processImgWithFilter(filter)
    }
}
// MARK:- GPUIMage处理方法
extension ViewController
{
    fileprivate func processImgWithFilter(_ filter : GPUImageFilter) -> UIImage
    {
        sourceImage.image = UIImage(named:"test")
        //1 创建用于处理单张图片(类似于美图秀秀中打开相册中的图片进行处理)
        let processImg = GPUImagePicture(image: sourceImage.image)
        
        //2. 添加滤镜
        processImg?.addTarget(filter)
        
        //3. 处理图片
        filter.useNextFrameForImageCapture()
        processImg?.processImage()
        
        //4. 获取处理后的图片
        return filter.imageFromCurrentFramebuffer()
    }
}


