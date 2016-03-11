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
    var path: String
    
    // MARK: - Init
    
    init(course: String, folder: String, name: String, link: String, path: String) {
        self.course = course
        self.folder = folder
        self.name = name
        self.link = link
        self.path = path
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
    
    func doYourThing(headers: [String: String], callback: (() -> Void)) {
        // print(link)
        if !fileExists() {
            Alamofire.request(.GET, link, headers: headers).response { (_, response, data, error) in
                if error != nil {
                    print("Error: \(error!)")
                } else {
                    self.checkFolderStructure(self.path)
                    data!.writeToFile(self.filePath(), atomically: false)
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
    
    func filePath() -> String {
        var filePath = path
        if course != "" {
            filePath += "/" + course
            if folder != "" {
                filePath += "/" + folder
                if name != "" {
                    filePath += "/" + name
                }
            }
        }
        return filePath
    }
    
    func fileExists() -> Bool {
        return NSFileManager.defaultManager().fileExistsAtPath(filePath())
    }
    
}