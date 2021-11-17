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
    var repository: VRTRepository!
    var annotations: [MKPointAnnotation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    private func initView() {
        configureRepository()
        configureMap()
        fetchPins()
    }
    
    private func configureRepository() {
        repository = VRTRepository(dataController: dataController)
    }
    
    private func fetchPins() {
        repository.getPins { pins, error in
            if let error = error {
                self.showErrorAlert(message: error.localizedDescription)
                return
            }
            
            print("Total PIN: \(pins.count)")
        }
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
                                        , latitudinalMeters: 5000, longitudinalMeters: 5000)
        let adjustRegion = mapView.regionThatFits(region)
        mapView.addAnnotation(annotation)
        mapView.setCenter(coordinate, animated: true)
        mapView.setRegion(adjustRegion, animated: true)
    }
    
    private func handleLocations(locations: [Pin], error:  Error?) {
        if let error = error {
            showErrorAlert(message: error.localizedDescription)
            return
        }
        
        mapView.removeAnnotations(annotations)
        annotations.removeAll()
        
        for location in locations {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            annotations.append(annotation)
            mapView.addAnnotation(annotation)
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
            
            let button = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = button
        } else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
    }
}

