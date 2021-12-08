//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Luis Alberto Rosas Arce on 15/11/21.
//

import UIKit
import MapKit
import CoreData

class TravelLocationViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Properties
    var dataController:DataController!
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    var pin: Pin!
    var pins: [Pin] = []
    
    var fetchedPhotoResultController: NSFetchedResultsController<Photo>!
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    // MARK: - Private methods
    private func initView() {
        configureMap()
        fetchPins(completion: handleFetchedPin(success:error:))
        showLastLocation()
    }
    
    private func configureMap() {
        mapView.delegate = self
        
        // Detect when user touches the map
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(userDidTapOnMap(gesture:)))
        mapView.addGestureRecognizer(gesture)
    }
    
    private func showLastLocation() {
        if let pin = fetchedResultsController.fetchedObjects?.last {
            let location = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            let region = MKCoordinateRegion(center: location
                                            , latitudinalMeters: 500, longitudinalMeters: 1000)
            let adjustRegion = mapView.regionThatFits(region)
            mapView.setCenter(location, animated: true)
            mapView.setRegion(adjustRegion, animated: true)
        }
    }
    
    @objc private func userDidTapOnMap(gesture: UIGestureRecognizer) {
        if gesture.state != .began { return }
        
        let touchPoint = gesture.location(in: mapView)
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        addAnnotationOnMap(coordinate: coordinate)
    }
    
    private func addAnnotationOnMap(coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        let region = MKCoordinateRegion(center: coordinate
                                        , latitudinalMeters: 1000, longitudinalMeters: 1000)
        let adjustRegion = mapView.regionThatFits(region)
        mapView.addAnnotation(annotation)
        mapView.setCenter(coordinate, animated: true)
        mapView.setRegion(adjustRegion, animated: true)
        savePin(coordinate: coordinate)
    }
    
    private func showPins() {
        for pin in fetchedResultsController.fetchedObjects ?? [] {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            mapView.addAnnotation(annotation)
        }
    }
    
    
    // MARK: - Handles
    private func handleFetchedPin(success: Bool, error: Error?) {
        if success {
            showPins()
        } else {
            self.showErrorAlert(message: error?.localizedDescription ?? "")
        }
    }
    
    // MARK: - Core Data
    func fetchPins(completion: @escaping (Bool, Error?) -> Void) {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pins")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            completion(true, nil)
        } catch {
            completion(false, error)
        }
    }
    
    func savePin(coordinate: CLLocationCoordinate2D) {
        pin = Pin(context: dataController.viewContext)
        pin.longitude = coordinate.longitude
        pin.latitude = coordinate.latitude
        try? dataController.viewContext.save()
        fetchPins(completion: handleFetchedPin(success:error:))
    }
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAlbum" {
            let destination = segue.destination as! PhotoAlbumViewController
            destination.pin = pin
            destination.dataController = dataController
            navigationItem.backButtonTitle = "OK"
        }
    }
}

extension TravelLocationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let pin = fetchedResultsController.fetchedObjects?.first(where: { $0.latitude == view.annotation?.coordinate.latitude && view.annotation?.coordinate.longitude == $0.longitude}) {
            self.pin = pin
            self.performSegue(withIdentifier: "showAlbum", sender: nil)
        }
        mapView.deselectAnnotation(view.annotation, animated: false)
    }
}

extension TravelLocationViewController: NSFetchedResultsControllerDelegate {
    
}

