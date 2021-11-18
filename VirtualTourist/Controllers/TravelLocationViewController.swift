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
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    var dataController:DataController!
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    var pin: Pin!
    
    var fetchedPhotoResultController: NSFetchedResultsController<Photo>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    private func initView() {
        configureMap()
        fetchPins(completion: handleFetchedPin(success:error:))
    }
    
    private func configureMap() {
        mapView.delegate = self
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(userDidTapOnMap(gesture:)))
        mapView.addGestureRecognizer(gesture)
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
    
    
    // MARK: - Handles
    private func handleFetchedPin(success: Bool, error: Error?) {
        if success {
            print("Total PIN: \(fetchedResultsController.fetchedObjects?.count ?? 0)")
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
        pin.createdAt = Date()
        try? dataController.viewContext.save()
    }
    
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAlbum" {
            let destination = segue.destination as! AlbumViewController
            destination.pin = pin
        }
    }
}

extension TravelLocationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Annotation")
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Annotation")
            annotationView?.canShowCallout = true
            
        } else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.performSegue(withIdentifier: "showAlbum", sender: nil)
        
//        repository.getPhotosByLocation(pin: pin) { response, error in
//            if let error = error {
//                self.showErrorAlert(message: error.localizedDescription)
//                return
//            }
//
//            self.performSegue(withIdentifier: "showAlbum", sender: nil)
//        }
    }
}

extension TravelLocationViewController: NSFetchedResultsControllerDelegate {
    
}

