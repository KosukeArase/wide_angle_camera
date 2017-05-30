//
//  ViewController.swift
//  jidori_cv
//
//  Created by AraseKosuke on 2015/12/17.
//  Copyright © 2015年 AraseKosuke. All rights reserved.
//


import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    
    // セッション
    var mySession : AVCaptureSession!
    // カメラデバイス
    var myDevice : AVCaptureDevice!
    // 出力先
    var myOutput : AVCaptureVideoDataOutput!
    
    var detector: Detector!
    
    var phase = 0
//    var base:UIImage


    override func viewDidLoad() {
        super.viewDidLoad()
        

        detector = Detector()
        // カメラを準備
        if initCamera() {
            // 撮影開始
            mySession.startRunning()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // カメラの準備処理
    func initCamera() -> Bool {
        // セッションの作成.
        mySession = AVCaptureSession()
        
        // 解像度の指定.
//        mySession.sessionPreset = AVCaptureSessionPresetMedium
        mySession.sessionPreset = AVCaptureSessionPresetiFrame1280x720
//        mySession.sessionPreset = AVCaptureSessionPreset640x480
        
        
        // デバイス一覧の取得.
        let devices = AVCaptureDevice.devices()
        
        // バックカメラをmyDeviceに格納.
        for device in devices {
//            if(device.position == AVCaptureDevicePosition.Front){
            if(device.position == AVCaptureDevicePosition.Front){
                myDevice = device as! AVCaptureDevice
            }
        }
        if myDevice == nil {
            return false
        }
        
        // バックカメラからVideoInputを取得.
//        let myInput = AVCaptureDeviceInput.deviceInputWithDevice(myDevice, error: nil) as AVCaptureDeviceInput
        do {

            let myInput = try AVCaptureDeviceInput(device: myDevice) as AVCaptureDeviceInput
            // セッションに追加.
            if mySession.canAddInput(myInput) {
                mySession.addInput(myInput)
            } else {
                return false
            }
            
            // 出力先を設定
            myOutput = AVCaptureVideoDataOutput()
            myOutput.videoSettings = [ kCVPixelBufferPixelFormatTypeKey: Int(kCVPixelFormatType_32BGRA) ]
            
            // FPSを設定
            do {
                try myDevice.lockForConfiguration()
                myDevice.activeVideoMinFrameDuration = CMTimeMake(1, 15)
                myDevice.unlockForConfiguration()
            } catch {
                print("error")
            return false
        }
        
        
        //            var lockError: NSError?
        //            if myDevice.lockForConfiguration(nil) {
        //                if let error = lockError {
        //                    println("lock error: \(error.localizedDescription)")
        //                    return false
        //                } else {
        //                    myDevice.activeVideoMinFrameDuration = CMTimeMake(1, 15)
        //                    myDevice.unlockForConfiguration()
        //                }
        //            }
        
        // デリゲートを設定
        let queue: dispatch_queue_t = dispatch_queue_create("myqueue",  nil)
        myOutput.setSampleBufferDelegate(self, queue: queue)
        
        
        // 遅れてきたフレームは無視する
        myOutput.alwaysDiscardsLateVideoFrames = true
        
        // セッションに追加.
        if mySession.canAddOutput(myOutput) {
            mySession.addOutput(myOutput)
        } else {
            return false
        }
        
        // カメラの向きを合わせる
        for connection in myOutput.connections {
            if let conn = connection as? AVCaptureConnection {
                if conn.supportsVideoOrientation {
//                    conn.videoOrientation = AVCaptureVideoOrientation.PortraitUpsideDown
                    conn.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
                }
            }
        }
        // UIボタンを作成.
        let myButton = UIButton(frame: CGRectMake(0,0,120,50))
        myButton.backgroundColor = UIColor.redColor();
        myButton.layer.masksToBounds = true
        myButton.setTitle("撮影", forState: .Normal)
        myButton.layer.cornerRadius = 20.0
        myButton.layer.position = CGPoint(x: self.view.bounds.width/2, y:50)//self.view.bounds.height-50)
        myButton.addTarget(self, action: "onClickMyButton:", forControlEvents: .TouchUpInside)
            
        // UIボタンをViewに追加.
        self.view.addSubview(myButton);
            
    } catch {
            print("error")
            return false
        }
        
        return true
    }
    
    
    // 毎フレーム実行される処理
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!)
    {
        dispatch_sync(dispatch_get_main_queue(), {
            
            /**
            *  ここでSampleBufferからUIImageを作成し、imageViewへ反映させる
            */
            let boundSize:CGSize = self.view.bounds.size
            self.imageView.contentMode = UIViewContentMode.ScaleAspectFit
            self.imageView.center = CGPointMake(boundSize.width/2, boundSize.height/2)
            let image = self.captureImage(sampleBuffer)
            
            switch self.phase {
                case 0:
                    self.imageView.image = image
                
                case 1:
                    self.detector.set_var_image1(image)
                    //                suke gazou
                    let dummy:Int32 = 0
                    let suke = self.detector.get_var_image(dummy)
                    let myImageView = UIImageView(image: suke)
                    let rect:CGRect = CGRectMake(15, 435, 340,200)//image.size.width*scale, image.size.height*scale)
                    // ImageView frame をCGRectMakeで作った矩形に合わせる
                    myImageView.frame = rect;
                    // view に ImageView を追加する
                    self.imageView2.addSubview(myImageView)
                    self.imageView2.alpha = 0.7
                    self.phase += 1
                
                case 2:
                    self.imageView.image = image
                    if self.detector.recognizeFace1(image) {
                        
                        self.imageView2.removeFromSuperview()
                        self.detector.set_var_image2(image)
                        let dummy:Int32 = 0
                        let suke = self.detector.get_var_image(dummy)
                        let myImageView = UIImageView(image: suke)
                        let rect:CGRect = CGRectMake(12, 32, 120,600)//image.size.width*scale, image.size.height*scale)
                        myImageView.frame = rect;
                        self.imageView3.addSubview(myImageView)
                        self.imageView3.alpha = 0.7
                        self.phase += 1
                    }
                
                case 3:
                    self.imageView.image = image
                    if self.detector.recognizeFace2(image) {
                        self.imageView3.removeFromSuperview()
                        self.detector.set_var_image3(image)
                        let dummy:Int32 = 0
                        let suke = self.detector.get_var_image(dummy)
                        let myImageView = UIImageView(image: suke)
                        let rect:CGRect = CGRectMake(15, 35, 340,200)//image.size.width*scale, image.size.height*scale)
                        myImageView.frame = rect;
                        self.imageView4.addSubview(myImageView)
                        self.imageView4.alpha = 0.7
                        self.phase += 1
                    }
                
                case 4:
                    self.imageView.image = image
                    if self.detector.recognizeFace3(image) {
                        self.imageView4.removeFromSuperview()
                        self.phase += 1
                        //                    self.detector.set_var_image4(image)
                        //                    let dummy:Int32 = 0
                        //                    let suke = self.detector.get_var_image(dummy)
                        //                    let myImageView = UIImageView(image: suke)
                        //                    let rect:CGRect = CGRectMake(15, 35, 340,200)//image.size.width*scale, image.size.height*scale)
                        //                    myImageView.frame = rect;
                        //                    self.imageView4.addSubview(myImageView)
                        //                    self.imageView4.alpha = 0.7
                        //                    self.phase = 4
                    }
                
                default:
                    print("aaaaaaaaaaaaaaaaaaaa")
                    let dummy:Int32 = 0
//                    let myImage:UIImage = self.detector.compose(dummy)
//                    self.imageView.image = myImage
//                UIImageWriteToSavedPhotosAlbum(myImage, self, nil, nil)
                    let myImage1:UIImage = self.detector.get_image1(dummy)
                    UIImageWriteToSavedPhotosAlbum(myImage1, self, nil, nil)
                    let myImage2:UIImage = self.detector.get_image2(dummy)
                    UIImageWriteToSavedPhotosAlbum(myImage2, self, nil, nil)
                    
                    
                    
                //                let dummy:Int32 = 0
//                    let image1 = self.detector.get_image1(dummy)
//                    let image2 = self.detector.get_image2(dummy)
//                    let image3 = self.detector.get_image3(dummy)
//                    let image4 = self.detector.get_image4(dummy)
////                                var myImageView = UIImageView(image: image1)
//                    
//                    switch 5 {
//                        case 0:
//                            self.imageView.image = image1
                            sleep(3)
//                    case 1:
//                    self.imageView.image = image2
//                    sleep(1)
//                    case 2:
//                    self.imageView.image = image3
//                    sleep(1)
//                    case 3:
//                    self.imageView.image = image4
//                    sleep(1)
//                    default:
//                        break
//                }

            }
            
        })
    }
    
    func onClickMyButton(sender: UIButton){
        
        self.phase = 1;
        
//        // ビデオ出力に接続.
//        let myVideoConnection = myImageOutput.connectionWithMediaType(AVMediaTypeVideo)
//        
//        // 接続から画像を取得.
//        self.myImageOutput.captureStillImageAsynchronouslyFromConnection(myVideoConnection, completionHandler: { (imageDataBuffer, error) -> Void in
//            
//            // 取得したImageのDataBufferをJpegに変換.
//            let myImageData : NSData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataBuffer)
//            
//            // JpegからUIIMageを作成.
//            let myImage : UIImage = UIImage(data: myImageData)!
//            
//            // アルバムに追加.
//            UIImageWriteToSavedPhotosAlbum(myImage, self, nil, nil)
//            
//        })
    }


    func captureImage(sampleBuffer:CMSampleBufferRef) -> UIImage{
        
        // Sampling Bufferから画像を取得
        let imageBuffer:CVImageBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer)!
        
        // pixel buffer のベースアドレスをロック
        CVPixelBufferLockBaseAddress(imageBuffer, 0)
        
        let baseAddress:UnsafeMutablePointer<Void> = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)
        
        let bytesPerRow:Int = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width:Int = CVPixelBufferGetWidth(imageBuffer)
        let height:Int = CVPixelBufferGetHeight(imageBuffer)
        
        
        // 色空間
        let colorSpace:CGColorSpaceRef = CGColorSpaceCreateDeviceRGB()!
        
        let bitsPerCompornent:Int = 8
        // swift 2.0
        let newContext:CGContextRef = CGBitmapContextCreate(baseAddress, width, height, bitsPerCompornent, bytesPerRow, colorSpace,  CGImageAlphaInfo.PremultipliedFirst.rawValue|CGBitmapInfo.ByteOrder32Little.rawValue)!
        
        let imageRef:CGImageRef = CGBitmapContextCreateImage(newContext)!
        let resultImage = UIImage(CGImage: imageRef, scale: 1.0, orientation: UIImageOrientation.Right)
        
        return resultImage
    }
    
    
}
