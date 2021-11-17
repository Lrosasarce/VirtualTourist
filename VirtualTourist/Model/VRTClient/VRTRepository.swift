//
//  VRTRepository.swift
//  VirtualTourist
//
//  Created by Luis Alberto Rosas Arce on 15/11/21.
//

import Foundation
import CoreData

class VRTRepository {
    
    var dataController: DataController!
    private var fetchedResultsController:NSFetchedResultsController<Pin>!
    weak var delegate: NSFetchedResultsControllerDelegate? = nil

    init(dataController: DataController) {
        self.dataController = dataController
    }
    
    func getPins(completion: @escaping ([Pin], Error?) -> Void) {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pins")
        fetchedResultsController.delegate = delegate
        do {
            try fetchedResultsController.performFetch()
            completion(fetchedResultsController.fetchedObjects ?? [], nil)
        } catch {
            completion([], error)
        }
    }
    
    func getPhotosByLocation(latitude: Double, longitude: Double) {
        
    }
    
}
