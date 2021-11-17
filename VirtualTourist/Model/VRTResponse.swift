//
//  VRTResponse.swift
//  VirtualTourist
//
//  Created by Luis Alberto Rosas Arce on 15/11/21.
//

import Foundation


struct VRTResponse: Codable {
    let status: String
    let code: Int
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case status = "stat"
        case code = "code"
        case message = "message"
        
    }
}

extension VRTResponse: LocalizedError {
    var errorDescription: String? {
        return message
    }
}

