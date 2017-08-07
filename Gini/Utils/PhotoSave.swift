//
//  PhotoSave.swift
//  Gini
//
//  Created by Nazar on 16/07/2017.
//  Copyright © 2017 Nazariy Bohun. All rights reserved.
//

import Foundation
import Photos


class PhotoSave: NSObject {
    
    static let albumName = "Gini_Demo"
    static let sharedInstance = PhotoSave()
    
    var assetCollection: PHAssetCollection!
    
    override init() {
        super.init()
        
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
        
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
                ()
            })
        }
        
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            self.createAlbum()
        } else {
            PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
        }
    }
    
    func requestAuthorizationHandler(status: PHAuthorizationStatus) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            // ideally this ensures the creation of the photo album even if authorization wasn't prompted till after init was done
            print("trying again to create the album")
            self.createAlbum()
        } else {
            print("should really prompt the user to let them know it's failed")
            MyAlertView.showInformationAlert(message: "You need to give proper access to your Photo Album")
        }
    }
    
    func createAlbum() {
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: PhotoSave.albumName)   // create an asset collection with the album name
        }) { success, error in
            if success {
                self.assetCollection = self.fetchAssetCollectionForAlbum()
            } else {
                //print("error: ",error)
            }
        }
    }
    
    func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", PhotoSave.albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let _: AnyObject = collection.firstObject {
            return collection.firstObject
        }
        return nil
    }
    
    func save(image: UIImage, completion: @escaping (_ localIdentifier:String?) -> Void) {
        if assetCollection == nil {
            return  // if there was an error upstream, skip the save
        }
        
        var imageIdentifier: String?
        
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
            let enumeration: NSArray = [assetPlaceHolder!]
            imageIdentifier = assetPlaceHolder?.localIdentifier
            
            albumChangeRequest!.addAssets(enumeration)
            
        }, completionHandler: { (success, error) -> Void in
            if success {
                completion(imageIdentifier)
            } else {
                completion(nil)
            }
        })
    }
}

extension PhotoSave {
    
    class func retrieveImageWithIdentifer(localIdentifier:String, completion: @escaping (_ image:UIImage?) -> Void)
    {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        let fetchResults = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: fetchOptions)
        
        if fetchResults.count > 0 {
            let imageAsset = fetchResults.object(at: 0)
            let requestOptions = PHImageRequestOptions()
            requestOptions.deliveryMode = .highQualityFormat
            PHImageManager.default().requestImage(for: imageAsset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: requestOptions, resultHandler: { (image, info) -> Void in
                completion(image)
            })
        } else {
            completion(nil)
        }
    }
    
    
    class func removeImageWithIdentifer(localIdentifier:String)
    {
        var assets:[PHAsset] = [PHAsset]()
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        let fetchResults = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: fetchOptions)
        
        if fetchResults.count > 0 {
            let imageAsset = fetchResults.object(at: 0)
            assets.append(imageAsset)
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.deleteAssets(assets as NSFastEnumeration)
            },completionHandler: {(success, error) in
                //print("success: \(success) | error: \(error)")
            })
        }
    }
    
}
