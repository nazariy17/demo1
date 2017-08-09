//
//  HomeController.swift
//  Gini
//
//  Created by Nazar on 14/07/2017.
//  Copyright © 2017 Nazariy Bohun. All rights reserved.
//

import Foundation

extension HomeView //Communication between Presenter and Interactor
{
    // this is SOLID class. It main obejctive is to receive data from Interactor and prepare it before sending to the VIEW
    // Receive interaction from view and make request for update to interactor
    // Presenter doesn't know from where the data is coming neither how the view is look like.
    
    //Since this is a simple example, our Presenter makes nothing at all, just passing data to Interactor
    
    
    // MARK DATA FETCHING
    
    func preGetDataForView()
    {
        intGetDataFromInternet(isAdditionalRequest: false)
    }
    
    func preGetAdditionalDataForView()
    {
        intGetDataFromInternet(isAdditionalRequest: true)
    }
    
    
    // MARK DATA SAVING
    
    func preSaveModelToFavorite(mImage:ModelImage)
    {
        intSaveModelToFavorite(mImage: mImage)
    }
    
    
    
    
    func preInsertImage(withItem item:ModelImage, at position:Int)
    {
        intInsertImage(withItem: item, at: position)
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

extension HomeView //Communication between Presenter and View
{
    
    func prePrepareDataForView(dataFromInternet: ResponseXML, isAdditionalRequest:Bool=false)
    {
        //convert ResponseXML to ModelImage since OUR View doesn't work with XML directly and for sake of encapsulation, neither should do it
        var responseData = [ModelImage]()
        
        //update main dataArray
        if isAdditionalRequest
        {
            responseData = dataArray
        }
        
        for image in dataFromInternet.data.images.image
        {
            let mImage = ModelImage(dictionary: image)
            responseData.append(mImage)
        }
        
        //if this is an update we should use proper method
        if isAdditionalRequest
        {
            appendData(newData: responseData)
        }
        else
        {
            updateArrayWithReceivedData(newData: responseData)
        }
        
    }
}
