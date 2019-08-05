//
//  StorageManger.swift
//  My Places
//
//  Created by Степан on 05.08.2019.
//  Copyright © 2019 Stepan. All rights reserved.
//

import RealmSwift

let realm = try! Realm()

class StorageManger {
    
    static func saveObject(_ place: Place) {
        
        try! realm.write {
            realm.add(place)
        }
    }
    
    static func deleteObject(_ place: Place) {
        
        try! realm.write {
            realm.delete(place)
        }
    }
}
