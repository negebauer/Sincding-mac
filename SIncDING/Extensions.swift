//
//  Extensions.swift
//  SIncDING
//
//  Created by Nicolás Gebauer on 12-03-16.
//  Copyright © 2016 Nicolás Gebauer. All rights reserved.
//

import Cocoa

extension NSViewController {
    
    func performSegueWithIdentifier(segue: Segue, sender: AnyObject?) {
        performSegueWithIdentifier(segue.rawValue, sender: sender)
    }
}

extension Bool {
    func nsState() -> Int {
        return self ? NSOnState : NSOffState
    }
}