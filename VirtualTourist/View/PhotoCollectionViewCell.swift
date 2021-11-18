//
//  PhotoCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Luis Alberto Rosas Arce on 18/11/21.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    static let cellID = "PhotoCollectionViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    class func getNib() -> UINib? {
        return UINib(nibName: cellID, bundle: nil)
    }

}
