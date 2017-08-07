//
//  Database.swift
//
//  Created by Nazar on 14/07/2017.
//  Copyright © 2017 Nazariy Bohun. All rights reserved.
//

import Foundation
import RealmSwift


class Database
{
    static let realm = try! Realm()
    
    /// MARK Save/Create Entity
    class func saveEntities(entities: [Object])
    {
        try! realm.write {
            realm.add(entities, update: true)
        }
    }
    
    
    /// MARK Delete Entitie
    class func deleteEntitie(entity: Object)
    {
        try! realm.write {
            realm.delete(entity)
        }
    }
    
    
    // MARK fetch DATA
    class func getAllFavorites() -> [ModelImage]
    {
        return realm.objects(ModelImage.self).sorted(byKeyPath: "id", ascending: false).map{$0}
    }
    
    class func getFavoriteByID(modelID:String) -> ModelImage?
    {
        return realm.objects(ModelImage.self).filter("id == '\(modelID)'").sorted(byKeyPath: "id", ascending: false).map{$0}.first
    }
    
    // we have to do it almost manually since REALM doesn't allow multi threading and we only can read / save / change on the save thread.
    class func updateImageLocalIDWithThreadSafe(modelID: String, localID:String)
    {
        DispatchQueue(label: "realm_id_thread").sync {
            let realm = try! Realm()
            
            let mImage = realm.objects(ModelImage.self).filter("id == '\(modelID)'").sorted(byKeyPath: "id", ascending: false).map{$0}.first
            
            if let entity = mImage {
                try! realm.write {
                    entity.localID = localID
                    realm.add(entity, update: true)
                }
            }

        }
    }
    
}

