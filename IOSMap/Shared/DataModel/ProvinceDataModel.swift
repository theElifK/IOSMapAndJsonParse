//
//  ProvinceDataModel.swift
//  IOSMap
//
//  Created by Elif Karakolcu on 13.03.2023.
//

import Foundation

struct DataModel: Codable {
    let data: [ProvinceDataModel]?
    
}

struct ProvinceDataModel: Codable {
    let name: String?
    let id: Int?
    let latitude: String?
    let longitude: String?
    let population: Int?
    let region: String?
    
}
