//
//  SidingParserDelegate.swift
//  SIncDING
//
//  Created by Nicolás Gebauer on 12-03-16.
//  Copyright © 2016 Nicolás Gebauer. All rights reserved.
//

import Foundation

protocol SidingParserDelegate: class {
    
    func indexedFiles(checked: Int, total: Int, new: Int)
    func syncedFiles(synced: Int, total: Int)
}