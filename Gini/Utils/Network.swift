//
//  Network.swift
//  Gini
//
//  Created by Nazar on 09/08/2017.
//  Copyright © 2017 Nazariy Bohun. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage

class Network: NSObject {
    
    private static var sharedInstance: Network = Network()
    var imageUrlString:String?
    
    let downloader = ImageDownloader(
        configuration: ImageDownloader.defaultURLSessionConfiguration(),
        downloadPrioritization: .fifo,
        maximumActiveDownloads: 4,
        imageCache: AutoPurgingImageCache(
            memoryCapacity: 100 * 1024 * 1024,
            preferredMemoryUsageAfterPurge: 60 * 1024 * 1024
        )
    )
    
    private override init() {}
    
    static func getSharedNetwork() -> Network {
        return sharedInstance
    }
    
    let imageCache = NSCache<NSString, UIImage>()
    
    
    /*** IMAGES ***/
    func loadImageUsingString(urlStr:String, callback: @escaping ((String, UIImage?) -> Void) ) {
        
        if let cachedImage = downloader.imageCache?.image(withIdentifier: urlStr) {
            print("Cached Image")
            callback(urlStr, cachedImage)
        } else {
            let urlRequest = URLRequest(url: URL(string: urlStr)!)
            downloader.download(urlRequest) { response in
                
                print("Image from Internet")
                
                let size = CGSize(width: 300.0, height: 300.0)
                let imageFilter = AspectScaledToFitSizeFilter(size: size)
                
                if let image = response.result.value {
                    callback(urlStr, imageFilter.filter(image))
                    return
                }
                callback(urlStr, nil)
            }
        }
    }
}
