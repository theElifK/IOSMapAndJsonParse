//
//  MKMapViewExtension.swift
//  IOSMap
//
//  Created by Elif Karakolcu on 14.03.2023.
//

import MapKit

public extension MKMapView{
    
    func fit(annos: [MKAnnotation]? = nil,
                 edgePadding: UIEdgeInsets = UIEdgeInsets(top: 25, left: 25, bottom: 25, right: 25)) {
            var zoomRect:MKMapRect = MKMapRect.null
            
            let annos = annos ?? self.annotations
            
            for index in 0..<annos.count {
                let annotation = annos[index]
                let aPoint:MKMapPoint = MKMapPoint(annotation.coordinate)
                let rect:MKMapRect = MKMapRect(x: aPoint.x, y: aPoint.y, width: 0.1, height: 0.1)
                
                if zoomRect.isNull {
                    zoomRect = rect
                } else {
                    zoomRect = zoomRect.union(rect)
                }
            }
            self.setVisibleMapRect(zoomRect, edgePadding: edgePadding, animated: true)
        }

    
    
}
