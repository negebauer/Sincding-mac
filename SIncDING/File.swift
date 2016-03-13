//
//  File.swift
//  SIncDING
//
//  Created by Nicolás Gebauer on 08-03-16.
//  Copyright © 2016 Nicolás Gebauer. All rights reserved.
//

import Foundation
import Alamofire

class File {
    
    // MARK: - Constants

    // MARK: - Variables
    
    var course: String
    var folder: String?
    var name: String?
    var link: String
    var parentPath: String
    var checked = false
    var synced = false
    
    // MARK: - Init
    
    init(course: String, folder: String?, name: String?, link: String, parentPath: String) {
        self.course = course
        self.folder = folder
        self.name = name
        self.link = link
        self.parentPath = parentPath
        if name != nil {
            checked = true
        }
        if exists() {
            synced = true
        }
    }
    
    // MARK: - Saving

    func download(headers: [String: String], callback: (() -> Void)) {
        guard isFile() else {
            checkFolderStructure()
            synced = true
            callback()
            return
        }
        Alamofire.request(.GET, link, headers: headers).response { (_, response, data, error) in
            if error != nil {
                print("Error: \(error!)")
            } else {
                self.checkFolderStructure()
                data!.writeToFile(self.path(), atomically: true)
            }
            self.synced = true
            callback()
        }
    }
    
    func checkFolderStructure() {
        if !NSFileManager.defaultManager().fileExistsAtPath(parentFolder()) {
            let _ = try? NSFileManager.defaultManager().createDirectoryAtPath(parentFolder(), withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    // MARK: - Helpers
    
    func isFile() -> Bool {
        let split = name?.componentsSeparatedByString(".")
        if split?.count > 1 && split?[1].characters.count < 5 {
            return true
        }
        return false
    }
    
    func isFolder() -> Bool {
        return !isFile()
    }
    
    func exists() -> Bool {
        return NSFileManager.defaultManager().fileExistsAtPath(path())
    }
    
    func path() -> String {
        var path = parentPath
        path += "/" + course
        if folder != nil {
            path += "/" + folder!
            if name != nil {
                path += "/" + name!
            }
        }
        return path
    }
    
    func parentFolder() -> String {
        if name == nil {
            return path()
        }
        let split = path().componentsSeparatedByString("/")
        let parentFolder = split[0...split.count - 2].joinWithSeparator("/")
        return parentFolder
    }
    
}