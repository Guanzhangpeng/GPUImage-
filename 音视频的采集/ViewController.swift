//
//  ViewController.swift
//  音视频的采集
//
//  Created by 管章鹏 on 2017/11/27.
//  Copyright © 2017年 管章鹏. All rights reserved.
//

import UIKit
import AVFoundation
class ViewController: UIViewController {

    fileprivate lazy var session : AVCaptureSession = AVCaptureSession()
    fileprivate var videoOutput : AVCaptureVideoDataOutput?
    fileprivate var previewLayer : AVCaptureVideoPreviewLayer?
    fileprivate var videoInput : AVCaptureDeviceInput?
    fileprivate var fileOutput : AVCaptureFileOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //1.0 初始化视频的输入和输出
        setupVideoInputOutput()
        
        //2.0 初始化音频的输入和输出
        setupAudioInputOutput()
        
        //3.0 初始化预览图层
//        setupPreviewLayer()
    }
    
}
// MARK:- 初始化方法
extension ViewController
{
    // MARK:- 初始化视频的输入和输出
    fileprivate func setupVideoInputOutput()
    {
        //1.0 添加视频的输入
        let devices : [AVCaptureDevice] = AVCaptureDevice.devices()
        guard let device =  devices.filter({$0.position == .front}).first else {return}
        guard  let input = try? AVCaptureDeviceInput(device: device) else {return}
        self.videoInput = input
        
        //2.0 添加视频的输出
        let output = AVCaptureVideoDataOutput()
        let queue = DispatchQueue.global()
        output.setSampleBufferDelegate(self, queue: queue)
        self.videoOutput = output
        
        //3.0 将输入和输出添加到session中
        session.beginConfiguration()
        if session.canAddInput(input)
        {
            session.addInput(input)
        }
        if session.canAddOutput(output) {
            session.canAddOutput(output)
        }
        session.commitConfiguration()
        
    }
    
    // MARK:- 初始化音频的输入和输出
    fileprivate func setupAudioInputOutput()
    {
        //1.0 添加音频的输入
        let device = AVCaptureDevice.default(for: AVMediaType.audio)!
        guard let input = try? AVCaptureDeviceInput(device: device) else {return}
        
        
        //2.0 添加音频的输出
        let output = AVCaptureAudioDataOutput()
        let queue = DispatchQueue.global()
        output.setSampleBufferDelegate(self, queue: queue)
        
        
        //3.0 将输入和输出添加到session中
        session.beginConfiguration()
        if session.canAddInput(input) {
            session.addInput(input)
        }
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        session.commitConfiguration()
    }
    
    // MARK:-  初始化预览图层
    fileprivate func setupPreviewLayer()
    {
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
        self.previewLayer =  previewLayer
    }
    
    // MARK:- 将录制视频写入沙盒
    fileprivate func setupMovieFileOutput()
    {
        //1.0 创建写入文件的输出
        let fileOutput = AVCaptureMovieFileOutput()
        self.fileOutput = fileOutput
        
        let connection = fileOutput.connection(with: AVMediaType.video)
        connection?.automaticallyAdjustsVideoMirroring = true
        
        if session.canAddOutput(fileOutput) {
            session.addOutput(fileOutput)
        }
        
        //2.0 写入文件
        let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/first.mp4"
        let fileUrl = URL(fileURLWithPath: filePath)
        fileOutput.startRecording(to: fileUrl, recordingDelegate: self)
        
    }
}
// MARK:- AVCaptureVideoDataOutputSampleBufferDelegate ---代理方法
extension ViewController:AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate
{
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if connection == videoOutput?.connection(with: AVMediaType.video)
        {
            print("采集视频数据")
        }
        else{
            print("采集音频数据")
        }
    }
}
// MARK:- AVCaptureFileOutputRecordingDelegate -- 代理方法
extension ViewController :AVCaptureFileOutputRecordingDelegate
{
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("开始写入文件")
    }
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("结束写入文件")
    }
}
// MARK:- 数据采集的控制方法
extension ViewController {
    @IBAction func routateCamera(_ sender: Any) {
        
        // 0.执行动画
        let rotaionAnim = CATransition()
        rotaionAnim.type = "oglFlip"
        rotaionAnim.subtype = "fromLeft"
        rotaionAnim.duration = 0.5
        view.layer.add(rotaionAnim, forKey: nil)
        
        guard let videoInput = videoInput else {
            return
        }
        let position :AVCaptureDevice.Position = videoInput.device.position == .front ? .back : .front
        let devices : [AVCaptureDevice] = AVCaptureDevice.devices()
        guard  let device = devices.filter({$0.position == position}).first else {return}
        guard let newInput = try? AVCaptureDeviceInput(device: device) else {return}
        
        //移除之前的input,添加新的input
        session.beginConfiguration()
          session.removeInput(videoInput)
        if  session.canAddInput(newInput)
        {
            session.addInput(newInput)
        }
        
        session.commitConfiguration()
        //保存新的Input
        self.videoInput = newInput
    }
    @IBAction func startCapture(_ sender: Any) {
        
        session.startRunning()
        setupPreviewLayer()
        
        //开始写入沙盒
        setupMovieFileOutput()
        
    }
    @IBAction func endCapture(_ sender: Any) {
        //1.0 停止写入
        fileOutput?.stopRecording()
        session.stopRunning()
        self.previewLayer?.removeFromSuperlayer()
    }
}

