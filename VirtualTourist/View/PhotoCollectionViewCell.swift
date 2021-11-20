//
//  PhotoCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Luis Alberto Rosas Arce on 18/11/21.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImage: UIImageView!
    
    static let cellID = "PhotoCollectionViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(data: Data?) {
        if let data = data {
            photoImage.image = UIImage(data: data)
            photoImage.contentMode = .center
        }
    }
    
    
    
    class func getNib() -> UINib? {
        return UINib(nibName: cellID, bundle: nil)
    }

}
