//
//  AppDelegate.swift
//  Trax
//
//  Created by H Hugo Falkman on 2015-04-22.
//  Copyright (c) 2015 H Hugo Fakman. All rights reserved.
//

import UIKit

struct GPXURL
{
    static let Notification = "GPXURL Notification"
    static let Key = "GPXURL URL Key"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{

    var window: UIWindow?

    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        let center = NSNotificationCenter.defaultCenter()
        let notification = NSNotification(name: GPXURL.Notification, object: self, userInfo: [GPXURL.Key:url])
        center.postNotification(notification)
        return true
    }
}

