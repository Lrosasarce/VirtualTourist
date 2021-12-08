//
//  Photo+Extension.swift
//  VirtualTourist
//
//  Created by Luis Alberto Rosas Arce on 18/11/21.
//

import Foundation
import CoreData

extension Photo {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        createdAt = Date()
    }
}
