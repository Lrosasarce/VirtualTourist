//
//  PhotoResponse.swift
//  VirtualTourist
//
//  Created by Luis Alberto Rosas Arce on 17/11/21.
//

import Foundation

struct PhotoResponse: Codable {
    let photos: PhotoResult
    let stat: String
}

// MARK: - Photos
struct PhotoResult: Codable {
    let page, pages, perpage, total: Int
    let photo: [PhotoEntity]
}

// MARK: - Photo
struct PhotoEntity: Codable {
    let id: String
    let owner: String
    let secret, server: String
    let farm: Int
    let title: String
    let ispublic, isfriend, isfamily: Int
}
