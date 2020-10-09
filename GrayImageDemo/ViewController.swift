//
//  ViewController.swift
//  GrayImageDemo
//
//  Created by tangchi on 2020/10/9.
//  Copyright © 2020 none. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let testImage = UIImage(named: "romantic_racing_car")
        let grayImage = testImage?.grayFilter
        let imgView = UIImageView(image: grayImage)
        view.addSubview(imgView)
        
        imgView.frame = CGRect(origin: .zero, size: grayImage?.size ?? .zero)
        imgView.center = view.center
        
    }
    
}

extension UIImage {
    
    var grayFilter: UIImage? {
        
        let size = CGSize(width: self.size.width * self.scale, height: self.size.height * self.scale)
        
        let colorSpace = CGColorSpaceCreateDeviceGray()
        
        guard let context = CGContext(data: nil,
                                      width: Int(size.width),
                                      height: Int(size.height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: 0,
                                      space: colorSpace,
                                      bitmapInfo: CGImageByteOrderInfo.orderDefault.rawValue) else {
                                        return nil
        }
        
        guard let cgImage = self.cgImage else { return nil }
        
        let imageRect = CGRect(origin: .zero, size: size)
        
        context.draw(cgImage, in: imageRect)
        
        guard let imageRef = context.makeImage() else { return nil }
        
        let alphaInfo = cgImage.alphaInfo
        
        let opaque = alphaInfo == .noneSkipLast || alphaInfo == .noneSkipFirst || alphaInfo == .none
        
        guard !opaque else {
            let grayImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
            return grayImage
        }
        
        // 构建上下文：每个像素一个字节，无alpha
        guard let alphaContext = CGContext(data: nil,
                                           width: Int(size.width),
                                           height: Int(size.height),
                                           bitsPerComponent: 8,
                                           bytesPerRow: 0,
                                           space: colorSpace,
                                           bitmapInfo: CGImageAlphaInfo.alphaOnly.rawValue) else {
                                            return nil
        }
        
        alphaContext.draw(cgImage, in: imageRect)
        
        guard let mask = alphaContext.makeImage() else { return nil }
        
        guard let maskedGrayImageRef = imageRef.masking(mask) else { return nil }
        let grayImage: UIImage = UIImage(cgImage: maskedGrayImageRef, scale: self.scale, orientation: self.imageOrientation)
        
        //TODO: 貌似不需要这段
//        // 用 CGBitmapContextCreateImage 方式创建出来的图片，CGImageAlphaInfo 总是为 CGImageAlphaInfoNone，导致 qmui_opaque 与原图不一致，所以这里再做多一步
//        let image = _imageWithSize(size: grayImage.size, opaque: opaque, scale: grayImage.scale, actions: { (context) in
//            grayImage.draw(in: CGRect(origin: .zero, size: grayImage.size))
//        })
//
//        guard let img = image else { return grayImage }
//
//        grayImage = img
        
        return grayImage
    }
    
//    func _imageWithSize(size: CGSize, opaque: Bool, scale: CGFloat, actions:(CGContext?)->(Void)) -> UIImage? {
//
//        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
//        let context = UIGraphicsGetCurrentContext()
//        actions(context)
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return image
//
//    }
    
}

