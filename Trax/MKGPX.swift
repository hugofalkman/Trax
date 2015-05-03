//
//  MKGPX.swift
//  Trax
//
//  Created by H Hugo Falkman on 2015-05-03.
//  Copyright (c) 2015 H Hugo Fakman. All rights reserved.
//

import MapKit

extension GPX.Waypoint: MKAnnotation {
    
    // MARK: - MKAnnotation
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var title: String! { return name }
    
    var subtitle: String! { return info }
    
    // MARK: - Links to Images
    
    
}