import UIKit
import Interstellar

class SignalDatasource<T>: NSObject, Datasource {
    private let tableView: UITableView?
    private let collectionView: UICollectionView?
    private let identifier: String
    private let tableCellGenerator: ((T, UITableViewCell) -> UITableViewCell)?
    private let collectionCellGenerator: ((T, UICollectionViewCell) -> UICollectionViewCell)?
    private var signal = Signal<[T]>()
    private var _bridge: Databridge!
    
    init(tableView: UITableView, identifier: String, cellGenerator: (T, UITableViewCell) -> UITableViewCell ) {
        self.tableView = tableView
        self.collectionView = nil
        self.identifier = identifier
        self.tableCellGenerator = cellGenerator
        self.collectionCellGenerator = nil
    }
    
    init(collectionView: UICollectionView, identifier: String, cellGenerator: (T, UICollectionViewCell) -> UICollectionViewCell ) {
        self.tableView = nil
        self.collectionView = collectionView
        self.identifier = identifier
        self.tableCellGenerator = nil
        self.collectionCellGenerator = cellGenerator
    }
    
    func attachSignal(signal:Signal<[T]>){
        self.signal = signal >>> Thread.main
        self.tableView?.dataSource = bridge()
        self.collectionView?.dataSource = bridge()
        self.signal.subscribe { result in
            self.tableView?.reloadData()
            self.collectionView?.reloadData()
        }
    }
    
    func bridge() -> Databridge {
        if _bridge == nil {
            _bridge = Databridge(datasource: self)
        }
        return _bridge
    }
    
    func itemForIndexPath(indexPath: NSIndexPath) -> T? {
        return signal.peek()?[indexPath.row]
    }
    
    func numberOfItemsInSection(section: Int) -> Int {
        if let items = signal.peek() {
            return items.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! UITableViewCell
        let object = itemForIndexPath(indexPath)!
        return tableCellGenerator!(object, cell)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! UICollectionViewCell
        let object = itemForIndexPath(indexPath)!
        return collectionCellGenerator!(object, cell)
    }
}
