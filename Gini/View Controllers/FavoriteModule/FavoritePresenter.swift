//
//  FavoritePresenter.swift
//  Gini
//
//  Created by Nazar on 15/07/2017.
//  Copyright © 2017 Nazariy Bohun. All rights reserved.
//

import Foundation

extension FavoriteView //Communication between Presenter and Interactor
{
    // MARK DATA FETCHING
    
    func preGetAllFavoritesImages() -> [ModelImage]
    {
        //we don't need to prepare the info
        return intGetAllFavoritesImages()
    }
    
    func preRemoveImage(at position:Int)
    {
        intRemoveImage(at: position)
    }
    
    func preGetDataLengt() -> Int
    {
        return dataArray.count
    }
}

extension FavoriteView //Communication between Presenter and View
{
    
}
