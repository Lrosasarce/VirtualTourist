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
    


}

extension AlbumViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.cellID, for: indexPath) as? PhotoCollectionViewCell else {
            return PhotoCollectionViewCell()
        }
        return cell
    }
}
