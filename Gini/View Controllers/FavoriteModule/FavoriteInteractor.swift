//
//  FavoriteInteractor.swift
//  Gini
//
//  Created by Nazar on 15/07/2017.
//  Copyright © 2017 Nazariy Bohun. All rights reserved.
//

import Foundation

extension FavoriteView
{
    // MARK DATA FETCHING
    
    func intGetAllFavoritesImages() -> [ModelImage]
    {
        return Database.getAllFavorites()
    }
    
    //Method responsible for removing an Image on specific position
    func intRemoveImage(at position:Int)
    {
        //remove from array in memore but also from REALM DB
        let item = dataArray[position]
        PhotoSave.removeImageWithIdentifer(localIdentifier: item.localID)
        dataArray.remove(at: position)
        
        Database.deleteEntitie(entity: item)
    }
    
}
