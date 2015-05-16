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
    
    var url: NSURL? {
        didSet {
            imageView.image = nil
            if let loadingUrl = url {
                loadImageAsync(loadingUrl) { image in
                    if loadingUrl == self.url {
                        self.imageView.image = image.value
                    }
                }
            }
        }
    }
    
    func loadImage(url: NSURL) -> Result<UIImage> {
        if let data = ImageCell.imageCache.objectForKey(url) as? NSData, image = UIImage(data: data) {
            return .Success(Box(image))
        } else {
            if let data = NSData(contentsOfURL: url), image = UIImage(data: data) {
                ImageCell.imageCache.setObject(data, forKey: url)
                return .Success(Box(image))
            } else {
                return .Error(NSError(domain: "Network", code: 404, userInfo: nil))
            }
        }
    }
    
    func loadImageAsync(url: NSURL, completion: Result<UIImage> -> Void) {
        let imageLoader = backgroundThread >>> loadImage >>> mainThread
        imageLoader(url) { image in
            if let image = image.value {
                completion(.Success(Box(image)))
            } else {
                completion(.Error(NSError(domain: "Image not found", code: 404, userInfo: nil)))
            }
        }
    }
    
}