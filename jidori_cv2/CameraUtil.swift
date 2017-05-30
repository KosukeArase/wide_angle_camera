
//
//  CameraUtil.swift
//  OpenCVSample
//
//  Created by gibachan on 2014/10/19.
//  Copyright (c) 2014年 gibachan. All rights reserved.
//
import Foundation
import UIKit
import AVFoundation

class CameraUtil {
    
    // sampleBufferからUIImageへ変換
    class func imageFromSampleBuffer(sampleBuffer: CMSampleBufferRef) -> UIImage {
        let imageBuffer: CVImageBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer)!
        
        // ベースアドレスをロック
        CVPixelBufferLockBaseAddress(imageBuffer, 0)
        
        // 画像データの情報を取得
        let baseAddress: UnsafeMutablePointer<Void> = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)
        
        let bytesPerRow: Int = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width: Int = CVPixelBufferGetWidth(imageBuffer)
        let height: Int = CVPixelBufferGetHeight(imageBuffer)
        
        // RGB色空間を作成
        let colorSpace: CGColorSpaceRef = CGColorSpaceCreateDeviceRGB()!
        
        // Bitmap graphic contextを作成
        let bitsPerCompornent: Int = 8
        var bitmapInfo = CGBitmapInfo(rawValue: (CGBitmapInfo.ByteOrder32Little.rawValue | CGImageAlphaInfo.PremultipliedFirst.rawValue))
        let newContext: CGContextRef = CGBitmapContextCreate(baseAddress, width, height, bitsPerCompornent, bytesPerRow, colorSpace, bitmapInfo.rawValue)! as CGContextRef
        
        // Quartz imageを作成
        let imageRef: CGImageRef = CGBitmapContextCreateImage(newContext)!
        
        // UIImageを作成
        let resultImage: UIImage = UIImage(CGImage: imageRef)
        
        return resultImage
    }
    
}
//import Foundation
//import UIKit
//import AVFoundation
//
//class CameraUtil {
//    
//    // sampleBufferからUIImageへ変換
//    class func imageFromSampleBuffer(sampleBuffer: CMSampleBufferRef) -> UIImage {
//        let imageBuffer: CVImageBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer)!
//        
//        // ベースアドレスをロック
//        CVPixelBufferLockBaseAddress(imageBuffer, 0)
//        
//        // 画像データの情報を取得
//        
//        let baseAddress = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)
//        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
//        let width = CVPixelBufferGetWidth(imageBuffer)
//        let height = CVPixelBufferGetHeight(imageBuffer)
//        
//        // RGB色空間を作成
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
//        
//        // Bitmap graphic contextを作成
//        let bitsPerCompornent: UInt = 8
//        var bitmapInfo = CGBitmapInfo(rawValue: (CGBitmapInfo.ByteOrder32Little.rawValue | CGImageAlphaInfo.PremultipliedFirst.rawValue))
//        
//        let context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, bitmapInfo.rawValue)
//        
//        
//        // Quartz imageを作成
//        let imageRef = CGBitmapContextCreateImage(context)
//        
//        // ベースアドレスをアンロック
//        CVPixelBufferUnlockBaseAddress(imageBuffer, 0)
//        
//        // UIImageを作成
//        let resultImage: UIImage = UIImage(CGImage: imageRef!)
//        
//        return resultImage
//    }
//    
//}
