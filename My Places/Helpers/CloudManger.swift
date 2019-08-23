//
//  CloudManger.swift
//  My Places
//
//  Created by Степан on 20.08.2019.
//  Copyright © 2019 Stepan. All rights reserved.
//

import UIKit
import CloudKit
import RealmSwift

class CloudManager {
    
    private static let privateCloudDatabase = CKContainer.default().publicCloudDatabase
    
    static func saveDataToCloud(place: Place, with image: UIImage, clouser: @escaping (String) -> ()) {
        
        let (image, url) = prepareImageToSaveToCloud(place: place, image: image)
        
        guard let imageAsset = image, let imageURL = url else { return }
        
        let record = CKRecord(recordType: "Place")
        record.setValue(place.placeID, forKey: "placeID")
        record.setValue(place.name, forKey: "name")
        record.setValue(place.location, forKey: "location")
        record.setValue(place.type, forKey: "type")
        record.setValue(place.rating, forKey: "rating")
        record.setValue(imageAsset, forKey: "imageData")
        
        privateCloudDatabase.save(record) { (newRecord, error) in
            if let error = error { print(error); return }
            if let newRecord = newRecord {
                clouser(newRecord.recordID.recordName)
            }
            deleteTempImage(imageURL: imageURL)
        }
    }
    
    static func fetchDataFromCloud(places: Results<Place>,closure: @escaping (Place) -> ()) {
        
        let query = CKQuery(recordType: "Place", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        privateCloudDatabase.perform(query, inZoneWith: nil) { (records, error) in
            
            guard error == nil else { print(error!); return}
            guard let records = records else {return}
            
            records.forEach({ (record) in
                
                let newPlace = Place(record: record)
                
                DispatchQueue.main.async {
                    if self.newCloudRecordIsAvailable(places: places, placeID: newPlace.placeID){
                        closure(newPlace)
                    }
                }
            })
        }
    }
    
    // MARK: Private Methods
    private static func prepareImageToSaveToCloud(place: Place, image: UIImage) -> (CKAsset?, URL?) {
        
        let scale = image.size.width > 1080 ? 1080 / image.size.width : 1
        let scaleImage = UIImage(data: image.pngData()!, scale: scale)
        let imageFilePath = NSTemporaryDirectory() + place.name
        let imageURL = URL(fileURLWithPath: imageFilePath)
        
        guard let dataToPath = scaleImage?.jpegData(compressionQuality: 1) else { return (nil, nil)}
        
        do {
            try dataToPath.write(to: imageURL, options: .atomic)
        } catch {
            print(error.localizedDescription)
        }
        
        let imageAsset = CKAsset(fileURL: imageURL)
        
        return (imageAsset, imageURL)
    }
    
    static private func deleteTempImage(imageURL: URL) {
        do {
            try FileManager.default.removeItem(at: imageURL)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private static func newCloudRecordIsAvailable(places: Results<Place>, placeID: String) -> Bool {
        for place in places {
            if place.placeID == placeID {
                return false
            }
        }
        
        return true
    }
}









