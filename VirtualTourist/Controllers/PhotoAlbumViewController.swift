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
    
    // MARK: - IBOUtlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var fetchButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    var pin: Pin!
    var dataController: DataController!
    var callRemoteService: Bool = false
    var fetchedResultsController: NSFetchedResultsController<Photo>?
    

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    // MARK: - Private methods
    private func initView() {
        addScreenValues()
        configureMapView()
        configureCollectionView()
        
        fetchPhotosByPin(pin)
        handleFetchedResult()
        
    }
    
    private func addScreenValues() {
        title = ""
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
        collectionView.delegate = self
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
        fetchedResultsController?.delegate = self

        do {
            try fetchedResultsController?.performFetch()
            callRemoteService = fetchedResultsController?.fetchedObjects?.isEmpty ?? true
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    private func handleFetchedResult() {
        if !callRemoteService {
            collectionView.reloadData()
        } else {
            fetchRemotePhotosByPin(pin)
        }
    }
    
    private func fetchRemotePhotosByPin(_ pin: Pin, page: Int? = nil) {
        callRemoteService = false
        fetchButton.isEnabled = false
        configureActivityIndicator(enabled: true)
        VRTClient.fetchPhotosByCoordinate(latitude: pin.latitude, longitude: pin.longitude, page: page, completion: handleRemotePhoto(photoResult:error:))
    }
    
    private func configureActivityIndicator(enabled: Bool) {
        mapView.isUserInteractionEnabled = !enabled
        enabled ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
    private func handleRemotePhoto(photoResult: PhotoResult?, error: Error?) {
        if let error = error {
            showErrorAlert(message: error.localizedDescription)
            configureActivityIndicator(enabled: false)
            return
        }
        
        guard let photos = photoResult?.photo else {
            return
        }
        
        for photo in photos {
            VRTClient.downloadPhotoImage(server: photo.server, id: photo.id, size: "w", secret: photo.secret) { data, error in
                self.savePhoto(response: photo, data: data!)
            }
        }
        fetchButton.isEnabled = !(photoResult?.photo.isEmpty ?? true)
        configureActivityIndicator(enabled: false)
        
    }
    
    // MARK: - Core Data Methods
    private func savePhoto(response: PhotoEntity, data: Data?) {
        let photo = Photo(context: dataController.viewContext)
        photo.id = response.id
        photo.image = data
        photo.pin = pin
        try? dataController.viewContext.save()
    }
    
    func deletePhoto(at indexPath: IndexPath) {
        let photoToDelete = fetchedResultsController?.object(at: indexPath)
        dataController.viewContext.delete(photoToDelete!)
        try? dataController.viewContext.save()
    }
    
    func deleteAlbum() {
        pin.photos = nil
        try? dataController.viewContext.save()
        collectionView.reloadData()
    }
    
    @IBAction func fetchBtnPressed(_ sender: UIButton) {
        deleteAlbum()
        let page = Int.random(in: 1..<5)
        fetchRemotePhotosByPin(pin, page: page)
    }
}

extension PhotoAlbumViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController?.sections?[0].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.cellID, for: indexPath) as? PhotoCollectionViewCell else {
            return PhotoCollectionViewCell()
        }
        let data = fetchedResultsController?.object(at: indexPath).image
        cell.configureCell(data: data)
        return cell
    }
}

extension PhotoAlbumViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        deletePhoto(at: indexPath)
        collectionView.reloadData()
    }
}


extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.reloadData()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.reloadData()
    }
}
