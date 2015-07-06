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
        
        gifSignal
        .bind(getURL)
        .ensure(Thread.background)
        .bind(loadFromCache)
        .bind(retryFromNetwork)
        .ensure(Thread.main)
        .next { image in
            self.imageView.image = image
        }
    }
    
    private func getURL(gif: Gif)->Result<NSURL> {
        return .Success(gif.url)
    }
    
    private func loadFromCache(url: NSURL)->Result<(UIImage?, NSURL)> {
        if let data = ImageCell.imageCache.objectForKey(url) as? NSData, image = UIImage(data: data) {
            return .Success((image as UIImage?, url))
        } else {
            let content: (UIImage?, NSURL) = (nil, url)
            return .Success(content)
        }
    }
    
    private func retryFromNetwork(image:(UIImage?, NSURL)) -> Result<UIImage>{
        if let image = image.0 {
            return .Success(image)
        } else {
            let url = image.1
            if let data = NSData(contentsOfURL: url), image = UIImage(data: data) {
                ImageCell.imageCache.setObject(data, forKey: url)
                return .Success(image)
            } else {
                return .Error(NSError(domain: "Network", code: 404, userInfo: nil))
            }
        }
    }
    
    func loadImageAsync(url: NSURL, completion: Result<UIImage>->Void) {
        Signal(url)
        .ensure(Thread.background)
        .bind(loadFromCache)
        .bind(retryFromNetwork)
        .ensure(Thread.main)
        .subscribe(completion)
    }
    
}