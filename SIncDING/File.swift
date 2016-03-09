//
//  File.swift
//  SIncDING
//
//  Created by Nicolás Gebauer on 08-03-16.
//  Copyright © 2016 Nicolás Gebauer. All rights reserved.
//

import Foundation
import Alamofire

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
    
    func doYourThing(path: String, headers: [String: String], callback: (() -> Void)) {
        print(link)
        let filePath = "\(path)/\(course)/\(folder)/\(name)"
        let fileExists = NSFileManager.defaultManager().fileExistsAtPath(filePath)
        if !fileExists {
            Alamofire.request(.GET, link, headers: headers).response { (_, response, data, error) in
                if error != nil {
                    print("Error: \(error!)")
                } else {
                    self.checkFolderStructure(path)
                    data!.writeToFile(filePath, atomically: false)
                }
                callback()
            }
        } else {
            callback()
        }
    }
    
    func checkFolderStructure(path: String) {
        let fileFolder = "\(path)/\(course)/\(folder)/"
        if !NSFileManager.defaultManager().fileExistsAtPath(fileFolder) {
            let _ = try? NSFileManager.defaultManager().createDirectoryAtPath(fileFolder, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
}