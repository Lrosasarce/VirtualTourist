//
//  Pin+Extension.swift
//  VirtualTourist
//
//  Created by Luis Alberto Rosas Arce on 16/11/21.
//

import Foundation
import CoreData

extension Pin {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        createdAt = Date()
    }
}
