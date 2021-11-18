//
//  VRTRepository.swift
//  VirtualTourist
//
//  Created by Luis Alberto Rosas Arce on 15/11/21.
//

import Foundation
import CoreData
import MapKit

class VRTRepository {
    
    var dataController: DataController!
    private var fetchedResultsController:NSFetchedResultsController<Pin>!
    private var fetchedPhotoResultsController:NSFetchedResultsController<Photo>!
    weak var delegate: NSFetchedResultsControllerDelegate? = nil

    init(dataController: DataController) {
        self.dataController = dataController
    }
    
    func fetchPhotosByPin(_ pin: Pin) -> [Photo] {
        
        return []
    }
    
    func savePin(coordinate: CLLocationCoordinate2D) -> Pin {
        let pin = Pin(context: dataController.viewContext)
        pin.longitude = coordinate.longitude
        pin.latitude = coordinate.latitude
        pin.createdAt = Date()
        try? dataController.viewContext.save()
        return pin
    }
    
    func savePhotos(pin: Pin)  {
        
    }
    
    func getPhotosStoraged(pin: Pin, completion: @escaping([Photo], Error?) -> Void) {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedPhotoResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(pin)-photos")
        fetchedPhotoResultsController.delegate = delegate

        do {
            try fetchedPhotoResultsController.performFetch()
            completion(fetchedPhotoResultsController.fetchedObjects ?? [], nil)
        } catch {
            completion([], error)
        }
    }
    
    
    func getRemotePhotosByPin(pin: Pin, completion: @escaping([Photo], Error?) -> Void) {
        VRTClient.shared.taskForGETRequest(url: VRTClient.Endpoints.photosByLocation(latitude: pin.latitude, longitude: pin.longitude).url, responseType: PhotoResponse.self) { response, error in
            if let error = error {
                completion([], error)
                return
            }
        }
    }
    
    
    func getPhotosByLocation(pin: Pin, completion: @escaping([Photo], Error?) -> Void) {
        getPhotosStoraged(pin: pin) { photos, error in
            if error != nil {
                self.getRemotePhotosByPin(pin: pin, completion: completion)
                return
            }
            
            if photos.isEmpty {
                self.getRemotePhotosByPin(pin: pin, completion: completion)
            }
            completion(photos, nil)
        }
    }
    
}
