//
//  AppDelegate.swift
//  Sincding
//
//  Created by Nicolás Gebauer on 08-03-16.
//  Copyright © 2016 Nicolás Gebauer. All rights reserved.
//

import Cocoa
import Fabric
import Crashlytics
import Sparkle
import UCSiding

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        Fabric.with([Crashlytics.self])
        SUUpdater.sharedUpdater().checkForUpdatesInBackground()
        NSUserDefaults.standardUserDefaults().registerDefaults(["NSApplicationCrashOnExceptions": true])
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}