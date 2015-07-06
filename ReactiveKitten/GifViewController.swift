//
//  GifViewController.swift
//  ReactiveKitten
//
//  Created by Jens Ravens on 16/05/15.
//  Copyright (c) 2015 nerdgeschoss GmbH. All rights reserved.
//

import Foundation
import UIKit

public class GifViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    let cell = ImageCell()
    
    public var gif: Gif?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        if let gif = gif {
            cell.loadImageAsync(gif.url) { image in
                self.imageView.image = image.value
            }
            label.text = gif.caption
        }
    }
    
    @IBAction public func share() {
        cell.loadImageAsync(gif!.url) { image in
            let items = NSMutableArray(object: image.value!)
            if let caption = self.gif?.caption {
                items.addObject(caption)
            }
            let vc = UIActivityViewController(activityItems: items as [AnyObject], applicationActivities: nil)
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }
}