//
//  File.swift
//  SIncDING
//
//  Created by Nicolás Gebauer on 08-03-16.
//  Copyright © 2016 Nicolás Gebauer. All rights reserved.
//

import Foundation

struct File {
    
    // MARK: - Constants

    // MARK: - Variables
    
    var course: String
    var folder: String
    var name: String
    var link: String
    
    // MARK: - Init
    
    init(course: String, folder: String, name: String, link: String) {
        self.course = course
        self.folder = folder
        self.name = name
        self.link = link
    }
    
    // MARK: - Functions

    func isFile() -> Bool {
        if name.containsString(".") {
            return false
        }
        return true
    }
    
    func isFolder() -> Bool {
        return !isFile()
    }
    
}