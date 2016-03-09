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
    
    func doYourThing(path: String) {
        //Get the local docs directory and append your local filename.
        //                        var docURL = (NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)).last! as NSURL
        //
        //                        docURL = docURL.URLByAppendingPathComponent( "myFileName.pdf")
        //
        //                        //Lastly, write your file to the disk.
        //                        data!.writeToURL(docURL, atomically: true)
        let filePath = "\(path)/\(course)/\(folder)/\(name)"
        var fileExists = NSFileManager.defaultManager().fileExistsAtPath(filePath)
        if !fileExists {
            print("Should create a file")
        }
    }
    
}