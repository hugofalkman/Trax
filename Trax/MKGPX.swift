//
//  MKGPX.swift
//  Trax
//
//  Created by H Hugo Falkman on 2015-05-03.
//  Copyright (c) 2015 H Hugo Fakman. All rights reserved.
//

import MapKit

class EditableWaypoint: GPX.Waypoint {
    
    override var coordinate: CLLocationCoordinate2D {
        get { return super.coordinate }
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
    }
    
    // for demo/debug/testing
    override var thumbnailURL: NSURL? { return imageURL }
    override var imageURL: NSURL? { return links.first?.url }
}

extension GPX.Waypoint: MKAnnotation {
    
    // MARK: - MKAnnotation
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var title: String! { return name }
    
    var subtitle: String! { return info }
    
    // MARK: - Links to Images
    
    var thumbnailURL: NSURL? { return getImageURLofType("thumbnail") }
    var imageURL: NSURL? { return getImageURLofType("large") }
    
    private func getImageURLofType(type: String) -> NSURL? {
        for link in links {
            if link.type == type {
                return link.url
            }
        }
        return nil
    }
}