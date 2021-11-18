//
//  AlbumViewController.swift
//  VirtualTourist
//
//  Created by Luis Alberto Rosas Arce on 17/11/21.
//

import UIKit
import CoreData
import MapKit

class AlbumViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var pin: Pin!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    private func initView() {
        addScreenValues()
        configureMapView()
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
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AlbumViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.cellID, for: indexPath) as? PhotoCollectionViewCell else {
            return PhotoCollectionViewCell()
        }
        return cell
    }
}
