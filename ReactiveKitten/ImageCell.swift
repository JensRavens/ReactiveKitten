//
//  ImageCell.swift
//  ReactiveKitten
//
//  Created by Jens Ravens on 16/05/15.
//  Copyright (c) 2015 nerdgeschoss GmbH. All rights reserved.
//

import Foundation
import UIKit
import Interstellar

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    static var imageCache = NSCache()
    
    let gifSignal = Signal<Gif>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        gifSignal.next { _ in
            self.imageView.image = nil
        }
        
        let imageSignal = gifSignal >>> getURL >>> Thread.background >>> loadFromCache >>> retryFromNetwork >>> Thread.main
        imageSignal.next { image in
            self.imageView.image = image
        }
    }
    
    private func getURL(gif: Gif)->Result<NSURL> {
        return .Success(Box(gif.url))
    }
    
    private func loadFromCache(url: NSURL)->Result<(UIImage?, NSURL)> {
        if let data = ImageCell.imageCache.objectForKey(url) as? NSData, image = UIImage(data: data) {
            return .Success(Box((image as UIImage?, url)))
        } else {
            return .Success(Box((nil, url)))
        }
    }
    
    private func retryFromNetwork(image:(UIImage?, NSURL)) -> Result<UIImage>{
        if let image = image.0 {
            return .Success(Box(image))
        } else {
            let url = image.1
            if let data = NSData(contentsOfURL: url), image = UIImage(data: data) {
                ImageCell.imageCache.setObject(data, forKey: url)
                return .Success(Box(image))
            } else {
                return .Error(NSError(domain: "Network", code: 404, userInfo: nil))
            }
        }
    }
    
    func loadImageAsync(url: NSURL, completion: Result<UIImage>->Void) {
        let process =  Thread.background |> loadFromCache |> retryFromNetwork |> Thread.main
        process(.Success(Box(url)), completion)
    }
    
}