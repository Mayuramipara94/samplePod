//
//  videoThumb.swift
//  EoMumbai
//
//  Created by Coruscate on 24/02/18.
//  Copyright © 2018 Coruscate's macmini. All rights reserved.
//

import UIKit
import AVFoundation
import SDWebImage

extension UIImageView {
    
    //Generate Video Thumb
    func setVideoThumb(url : String,placeHolder : UIImage?, completion : @escaping (() -> ())) {
        self.image = placeHolder
        
        if url.isYouTubeUrl() {
            
            //if is you tube video
            self.setYouTubeThumb(identifier: url.youtubeID ?? "", placeHolder: placeHolder, completion: completion)
        }
        else {
            
            if SDWebImageManager.shared().imageCache?.diskImageDataExists(withKey: url) == true {
                
                let tempImage = SDWebImageManager.shared().imageCache?.imageFromDiskCache(forKey: url)
                if tempImage != nil {
                    self.image = tempImage
                    completion()
                    return
                }
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                let asset: AVAsset = AVAsset(url: URL(string: url)!)
                let duration  = asset.duration.seconds;
                let imageGenerator = AVAssetImageGenerator(asset: asset)
                
                do {
                    let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: Int64(Int(duration)/2), timescale: 60) , actualTime: nil)
                    
                    DispatchQueue.main.async {
                        self.image = UIImage(cgImage: thumbnailImage)
                        
                        if self.image == nil {
                            self.image = placeHolder
                        }
                        else {
                            SDWebImageManager.shared().saveImage(toCache: UIImage(cgImage: thumbnailImage), for: URL(string: url))
                        }
                        completion()
                    }
                    
                } catch let error {
                    print(error)
                }
            }
        }
    }
    
    //You tube Url
    func setYouTubeThumb(identifier : String,placeHolder : UIImage?, completion : @escaping (() -> ())) {
        
        let urlStr = "http://img.youtube.com/vi/\(identifier)/0.jpg"
        self.sd_setImage(with: URL(string: urlStr)!, placeholderImage: placeHolder, options: SDWebImageOptions.continueInBackground) { (image, error, cacheType, Url) in
            
            if image != nil {
                self.image = image
                
            }
            else {
                self.image = placeHolder
            }
            
            completion()
        }
    }
}

class videoThumb: NSObject {

    // A Singleton instance
    static let sharedInstance = videoThumb()
    
    typealias myCompletion = (_ image : UIImage) -> Void
    typealias onCompletion = () -> Void
    
    // Initialize
    private override init() {
    }
    
    func generateThumb(url : String,placeHolder : UIImage,_ compblock : @escaping myCompletion)  {
        
        let asset: AVAsset = AVAsset(url: URL.init(string: url)!)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
            compblock(UIImage(cgImage: thumbnailImage))
            return
            
        } catch let error {
            print(error)
        }
        compblock(placeHolder)
    }
    
}
