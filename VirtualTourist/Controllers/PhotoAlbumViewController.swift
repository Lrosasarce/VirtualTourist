//
//  AlbumViewController.swift
//  VirtualTourist
//
//  Created by Luis Alberto Rosas Arce on 17/11/21.
//

import UIKit
import CoreData
import MapKit

class PhotoAlbumViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var pin: Pin!
    var dataController: DataController!
    var remoteServiceCalled: Bool = false
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    private func initView() {
        addScreenValues()
        configureMapView()
        
        fetchPhotosByPin(pin)
        configureCollectionView()
    }
    
    private func addScreenValues() {
        title = ""
        navigationController?.navigationBar.backItem?.title = "OK"
    }
    
    private func configureMapView() {
        let annotation = MKPointAnnotation()
        let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        annotation.coordinate = coordinate
        let region = MKCoordinateRegion(center: coordinate
                                        , latitudinalMeters: 1000, longitudinalMeters: 1000)
        let adjustRegion = mapView.regionThatFits(region)
        mapView.addAnnotation(annotation)
        mapView.setCenter(coordinate, animated: true)
        mapView.setRegion(adjustRegion, animated: true)
        mapView.isUserInteractionEnabled = false
    }
    
    private func configureCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 2
        flowLayout.minimumLineSpacing = 2
        
        let size = collectionView.frame.width/3 - 10
        flowLayout.itemSize = CGSize(width: size, height: size)
        
        collectionView.dataSource = self
        collectionView.collectionViewLayout = flowLayout
        collectionView.register(PhotoCollectionViewCell.getNib(), forCellWithReuseIdentifier: PhotoCollectionViewCell.cellID)
        collectionView.layoutIfNeeded()
    }
    
    private func fetchPhotosByPin(_ pin: Pin) {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(pin)-photos")
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    private func handleFetchedResult() {
        if remoteServiceCalled {
            collectionView.reloadData()
        
        } else {
            
        }
    }
    
    private func fetchRemotePhotosByPin(_ pin: Pin) {
        remoteServiceCalled = true
        VRTClient.fetchPhotosByCoordinate(latitude: pin.latitude, longitude: pin.longitude, completion: handleRemotePhoto(photoResult:error:))
    }
    
    private func handleRemotePhoto(photoResult: PhotoResult?, error: Error?) {
        if let error = error {
            showErrorAlert(message: error.localizedDescription)
            return
        }
        
        for photo in photoResult!.photo {
            VRTClient.downloadPhotoImage(server: photo.server, id: photo.id, size: "w") { data, error in
                self.savePhoto(response: photo, data: data!)
            }
        }
        collectionView.reloadData()
    }
    
    // MARK: - Core Data Methods
    private func savePhoto(response: PhotoEntity, data: Data) {
        let photo = Photo(context: dataController.viewContext)
        photo.id = response.id
        photo.image = data
        photo.createdAt = Date()
        try? dataController.viewContext.save()
    }
    

}

extension PhotoAlbumViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.cellID, for: indexPath) as? PhotoCollectionViewCell else {
            return PhotoCollectionViewCell()
        }
        return cell
    }
}


extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
}
