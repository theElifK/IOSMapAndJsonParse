//
//  CustomPointAnnotation.swift
//  IOSMap
//
//  Created by Elif Karakolcu on 14.03.2023.
//

import MapKit

open class CustomPointAnnotation: MKPointAnnotation{
    
    public var pinImageName: String!
    public var tag: Int!
    public var isDraggable: Bool!
    public var nickName: String! = String()
    public var id: Int = 0
    public var color: UIColor = .white
}
