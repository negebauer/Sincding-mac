//
//  Utilities.swift
//  WeMeep
//
//  Created by Nicolás Gebauer on 01-10-15.
//  Copyright © 2015 Nicolás Gebauer. All rights reserved.
//

/** Colection of global functions that are utilities for the project.
- Author: Nicolás Gebauer.
- Date: 01-09-15.
- Version: 0.1
*/

import Foundation

// MARK: - Main queue access

func mainQueue(block: () -> Void) {
    dispatch_async(dispatch_get_main_queue(), {
        block()
    })
}

func synced(lock: AnyObject, closure: () -> ()) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}