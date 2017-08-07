//
//  HomeCollectionCell.swift
//  Gini
//
//  Created by Nazar on 14/07/2017.
//  Copyright © 2017 Nazariy Bohun. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire

@objc protocol HomeCollectionCellDelegate {
    @objc optional func insertFavoriteCell(cell:HomeCollectionCell)
    @objc optional func removeFavoriteCell(cell:HomeCollectionCell)
    @objc optional func insertCell()
}

class HomeCollectionCell: UICollectionViewCell {
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellFavoriteBtn: UIButton! //I know some people doesn't like to use "cell" or "Btn" within the name, but I do because it's more explanatory
    @IBOutlet weak var cellLoader: UIActivityIndicatorView! // same here
    @IBOutlet weak var cellAddNewImagesBtn: UIButton!
    
    var isFavorite = false
    var delegate:HomeCollectionCellDelegate?
    
    //main function used by parent to set data
    func setImage(mImage:ModelImage, isFavorite:Bool)
    {
        self.isFavorite = isFavorite
        setCell(mImage: mImage)
    }
    
    func setCell(mImage:ModelImage)
    {
        //add action
        cellFavoriteBtn.addTarget(self, action: #selector(HomeCollectionCell.cellBtnAction), for: UIControlEvents.touchUpInside)
        cellAddNewImagesBtn.isHidden = true
        cellImage.isHidden = false
        
        if isFavorite
        {
            cellLoader.isHidden = true
            cellFavoriteBtn.setImage(Image(named:"icon_remove"), for: UIControlState.normal)
            PhotoSave.retrieveImageWithIdentifer(localIdentifier: mImage.localID, completion: { image in
                self.cellImage.image = image
            })
        }
        else
        {
            cellLoader.isHidden = false
            cellFavoriteBtn.setImage(Image(named:"icon_favorite"), for: UIControlState.normal)
            getImageFromInternet(urlString: mImage.url)
        }
    }
    
    func getImageFromInternet(urlString:String)
    {
        cellLoader.isHidden = false
        cellLoader.startAnimating()
        
        Alamofire.request(urlString).responseImage(completionHandler: { response in
            //debugPrint(response)
            //print("URL: \(urlString) | response.result: \(response.result)")
            
            switch response.result {
            case .success:
                print("self.cellImage: ",self.cellImage.image ?? "qqqq")
                if let image = response.result.value {
                    self.cellImage.image = image
                }
                self.cellFavoriteBtn.isHidden = false
            case .failure( _):
                //print("Error: ",error)
                let image = UIImage(named: "no_thumbnail")
                self.cellImage.image = image
                self.cellFavoriteBtn.isHidden = true //prevent adding no image to favorite
            }
            
            self.cellLoader.stopAnimating()
            self.cellLoader.isHidden = true
        })
    }
    
    func cellBtnAction()
    {
        if isFavorite
        {
            delegate?.removeFavoriteCell!(cell: self)
        }
        else
        {
            cellFavoriteBtn.isHidden = true //need to hide fav BTN
            delegate?.insertFavoriteCell!(cell: self)
        }
    }
    
    //This cell is used to add more 20 images
    func setLastCell()
    {
        cellAddNewImagesBtn.isHidden = false
        cellImage.isHidden = true
        cellLoader.isHidden = true
        cellFavoriteBtn.isHidden = true
        
        cellAddNewImagesBtn.addTarget(self, action: #selector(HomeCollectionCell.addNewCellAction), for: UIControlEvents.touchUpInside)
    }
    
    //Delegate to the parent
    func addNewCellAction()
    {
        delegate?.insertCell!() //will crash because of force unwrapping
    }
}
