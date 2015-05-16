import UIKit

protocol Datasource {
    func numberOfItemsInSection(section: Int) -> Int;
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell;
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell;
}

class Databridge : NSObject, UITableViewDataSource, UICollectionViewDataSource {
    let datasource: Datasource
    
    init(datasource: Datasource) {
        self.datasource = datasource
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.numberOfItemsInSection(section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return datasource.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource.numberOfItemsInSection(section)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return datasource.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
    }
}