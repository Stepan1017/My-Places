//
//  PlaceModel.swift
//  My Places
//
//  Created by Степан on 03.08.2019.
//  Copyright © 2019 Stepan. All rights reserved.
//

import RealmSwift
import CloudKit

class Place: Object {
    
    @objc dynamic var placeID = UUID().uuidString
    @objc dynamic var recordID = ""
    @objc dynamic var name = ""
    @objc dynamic var location: String?
    @objc dynamic var type: String?
    @objc dynamic var imageData: Data?
    @objc dynamic var date = Date()
    @objc dynamic var rating = 0.0
   
    convenience init(name: String, location: String?, type: String?, imageData: Data?, rating: Double) {
        self.init()
        self.name = name
        self.location = location
        self.type = type
        self.imageData = imageData
        self.rating = rating
    }
    
    convenience init(record: CKRecord) {
        self.init()
        
        guard let possibalImage = record.value(forKey: "imageData") else {return}
        let imageAsset = possibalImage as! CKAsset
        guard let imageData = try? Data(contentsOf: imageAsset.fileURL) else {return}
    
        self.placeID = record.value(forKey: "placeID") as! String
        self.recordID = record.recordID.recordName
        self.name = record.value(forKey: "name") as! String
        self.location = record.value(forKey: "location") as? String
        self.type = record.value(forKey: "type") as? String
        self.imageData = imageData
        self.rating = record.value(forKey: "rating") as! Double
    }
    
    override static func primaryKey() -> String? {
        return "placeID"
    }
        
}
