//
//  FavoriteView.swift
//  Gini
//
//  Created by Nazar on 15/07/2017.
//  Copyright © 2017 Nazariy Bohun. All rights reserved.
//

import UIKit
import SCLAlertView

class FavoriteView: UIViewController {
    
    @IBOutlet weak var uiCollectionView: UICollectionView!
    @IBOutlet weak var noImagesMsg: UILabel!
    
    let reuseIdentifier = "HomeCollectionCell" // also enter this string as the cell identifier in the storyboard
    var dataArray: [ModelImage] = []
    var deletePosition:Int? // is used to delete data from Collection / dataArray and DB. Need to save it because of AlertView
    
    
    /// MARK Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setup()
    {
        //get data (we shouldn't communicate to interactive directly because of the viper pattern
        dataArray = preGetAllFavoritesImages()
        uiCollectionView.reloadData()
        needToShowEmptyMsg()
    }
    
    //Show Label if we have no Favorite images
    func needToShowEmptyMsg()
    {
        if dataArray.count<1 { noImagesMsg.isHidden = false }
        else { noImagesMsg.isHidden = true }
    }
    
    
    func showInformationAlert(position:Int)
    {
        let mImage = dataArray[position]
        
        // the alert view
        let alert = UIAlertController(title: "UUID", message: "\(mImage.url)", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        
        // change to desired number of seconds (in this case 1 seconds)
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when){
            // your code with delay
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    
    //we can make this alert more GENERAL and move to UTIL folder
    func showDeleteAlert()
    {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("Yes", action:
            {
                () -> Void in
                guard let positionToRemove = self.deletePosition else { return }
                
                //Send action to Presenter to remove this Item from dataArray
                self.preRemoveImage(at: positionToRemove) //presenter
                
                //Update visualy th removal process
                self.uiCollectionView.performBatchUpdates({ () -> Void in
                    self.uiCollectionView.deleteItems(at: [IndexPath(item: positionToRemove, section: 0)])
                }, completion:nil)
                
                //clean delete value
                self.deletePosition = nil
                
                //Check if we still have some favourites
                self.needToShowEmptyMsg()
                
        })
        alert.addButton("Cancel", action: { () -> Void in
            alert.dismiss(animated: true, completion: nil)
            self.deletePosition = nil //clean delete val
        })
        
        guard let pos = deletePosition else { return }
        let uuid = dataArray[pos].id
        alert.showInfo("", subTitle: "Do you really want to remove from Favorite the item  with identifier \(uuid)?")
        
    }
}



extension FavoriteView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many sections to make
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return preGetDataLengt() // the extra cell is for add button
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! HomeCollectionCell
        cell.delegate = self
        
        //get data for current row
        let imgModel = dataArray[indexPath.row]
        
        //set a image.. let's delegate this job to the cell itself
        cell.setImage(mImage: imgModel, isFavorite: true )
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize = collectionView.frame.width/2-1 // 1->margin
        return CGSize(width: cellSize, height: cellSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        showInformationAlert(position: indexPath.row)
    }
}


extension FavoriteView: HomeCollectionCellDelegate {
    
    func removeFavoriteCell(cell: HomeCollectionCell) {
        guard let indexPath = uiCollectionView.indexPath(for: cell) else { return }
        
        deletePosition = indexPath.row
        showDeleteAlert()
    }
}
