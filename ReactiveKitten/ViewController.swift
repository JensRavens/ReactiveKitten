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
        
        signal = searchBar.textSignal >>> Network().search()
        
        datasource = SignalDatasource(collectionView: collectionView, identifier: "Cell") { gif, cell in
            if let cell = cell as? ImageCell {
                cell.url = gif.url
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
    
    func layoutItems(size: CGSize) {
        let size = size.width > 400 ? size.width/3 : size.width/2
        layout.itemSize = CGSize(width: size, height: size)
    }
}

var SignalHandle: UInt8 = 0
extension UISearchBar: UISearchBarDelegate {
    public var textSignal: Signal<String> {
        let signal: Signal<String>
        if let handle = objc_getAssociatedObject(self, &SignalHandle) as? Signal<String> {
            signal = handle
        } else {
            signal = Signal("")
            delegate = self
            objc_setAssociatedObject(self, &SignalHandle, signal, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        }
        return signal
    }
    
    public func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if count(searchText) > 0 {
            textSignal.update(.Success(Box(self.text)))
        } else {
            textSignal.update(.Error(NSError(domain: "User", code: 404, userInfo: nil)))
        }
    }
    
    public func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        resignFirstResponder()
    }
    
    public func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        setShowsCancelButton(true, animated: true)
    }
    
    public func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        setShowsCancelButton(false, animated: true)
    }
}
