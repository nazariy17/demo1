//
//  Pin.swift
//  Gini
//
//  Created by Nazar on 14/07/2017.
//  Copyright © 2017 Nazariy Bohun. All rights reserved.
//

import Foundation
import RealmSwift


/*
 We use REALM to save data in persistent way.
 Realm interface is much cleaner and easier to understand
*/

class ModelImage: Object
{
    dynamic var id          = ""
    dynamic var url         = ""
    dynamic var source_url  = ""
    dynamic var localID  = ""
    dynamic var isFavorite  = false
    
    override static func primaryKey() -> String?
    {
        return "id"
    }
    
    convenience init(dictionary: ImageXML) {
        self.init()
        
        if let id = dictionary.id {
            self.id = id
        }
        
        if let url = dictionary.url {
            self.url = url
        }
        
        if let source_url = dictionary.source_url {
            self.source_url = source_url
        }
        
        self.localID = ""
        self.isFavorite = false
    }
}

extension ModelImage {
    
    // get all favorite images saved on disk
    class func getFavoriteImages() -> [ModelImage]
    {
        return [ModelImage]()
    }
}
