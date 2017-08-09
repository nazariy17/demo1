//
//  HomeInteractor.swift
//  Gini
//
//  Created by Nazar on 14/07/2017.
//  Copyright © 2017 Nazariy Bohun. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireXmlToObjects

extension HomeView
{
    //This extension is also SOLID and it job consists in data processing and BI. It can make request to some API, communicate with DataBase, etc. All data task related functions should be here.
    //Interactor doesn't know nothing about presenter neither view. It only works/process with data.
    
    // MARK DATA FETCHING
    
    func intGetDataFromInternet(isAdditionalRequest:Bool)
    {
        let URL = "http://thecatapi.com/api/images/get?format=xml&results_per_page=\(numberOfPictures)&size=small&type=jpg,png"
        
        Alamofire.request(URL).responseObject { (response: DataResponse<ResponseXML>) in
                if let result = response.value {
                    // right here we have our XML in ResponseXML... need to convert to ModelImage so we can work, delegate to Presenter
                    self.prePrepareDataForView(dataFromInternet: result, isAdditionalRequest: isAdditionalRequest)
                }
        }
    }
    
    func intGetAllFavoritesImages() -> [ModelImage]
    {
        return Database.getAllFavorites()
    }
    
    
    // MARK DATA SAVING
    
    func intSaveModelToFavorite(mImage:ModelImage)
    {
        Database.saveEntities(entities: [mImage])
        mImageID = mImage.id
        
        //save image
        Alamofire.request(mImage.url).responseImage(completionHandler: { response in
            if let image = response.result.value {
                let photoAlbum = PhotoSave()
                
                photoAlbum.save(image: image, completion: { (localIdentifier) -> Void in
                    if let unwrapedID = localIdentifier {
                        Database.updateImageLocalIDWithThreadSafe(modelID: self.mImageID, localID: unwrapedID)
                    }
                })
            }
        })
    }
    
    
    func intInsertImage(withItem item:ModelImage, at position:Int)
    {
        dataArray.insert(item, at: position)
    }
    
    
    //Method responsible for removing an Image on specific position
    func intRemoveImage(at position:Int)
    {
        dataArray.remove(at: position)
    }
    
}
