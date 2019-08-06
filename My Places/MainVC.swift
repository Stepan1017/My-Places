//
//  MainVC.swift
//  My Places
//
//  Created by Степан on 31.07.2019.
//  Copyright © 2019 Stepan. All rights reserved.
//

import UIKit
import RealmSwift

class MainVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var places: Results<Place>!
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        places = realm.objects(Place.self)

    }

    // MARK: - Table view data source
 
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return places.isEmpty ? 0 : places.count

    }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell

        let place = places[indexPath.row]

        cell.nameLabel?.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)



        cell.imageOfPlace?.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2
        cell.imageOfPlace?.clipsToBounds = true

        return cell

    }
    
    // MARK: - Table view delegate
    
     func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) ->
        [UITableViewRowAction]? {
        
            let place = places[indexPath.row]
            let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (_, _) in
                
                StorageManger.deleteObject(place)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
            return [deleteAction]
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let place = places[indexPath.row]
            let newPlaceVC = segue.destination as! NewPlaceVC
            newPlaceVC.currentPlace = place
            
        }
    }
 
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        
        guard let newPlaceVC = segue.source as? NewPlaceVC else {return}
        
        newPlaceVC.savePLace()
        tableView.reloadData()
    }

}





















