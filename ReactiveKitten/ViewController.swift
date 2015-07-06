//
//  ViewController.swift
//  ReactiveKitten
//
//  Created by Jens Ravens on 16/05/15.
//  Copyright (c) 2015 nerdgeschoss GmbH. All rights reserved.
//

import UIKit
import Interstellar

class ViewController: UIViewController {
    var signal: Signal<[Gif]>!
    var datasource: SignalDatasource<Gif>!
    @IBOutlet weak var collectionView: UICollectionView!
    var layout: UICollectionViewFlowLayout!
    let searchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        navigationItem.titleView = searchBar
        searchBar.keyboardAppearance = .Dark
        
        signal = searchBar.textSignal.bind(Network().search)
        
        searchBar.textSignal.update(.Success("kitten"))
        
        datasource = SignalDatasource(collectionView: collectionView, identifier: "Cell") { gif, cell in
            if let cell = cell as? ImageCell {
                cell.gifSignal.update(.Success(gif))
            }
            return cell
        }
        datasource.attachSignal(signal)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        layoutItems(collectionView.bounds.size)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        layoutItems(size)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dst = segue.destinationViewController as? GifViewController,
            cell = sender as? ImageCell {
                dst.gif = cell.gifSignal.peek()!
        }
    }
    
    func layoutItems(size: CGSize) {
        let size = size.width > 400 ? size.width/3 : size.width/2
        layout.itemSize = CGSize(width: size, height: size)
    }
}