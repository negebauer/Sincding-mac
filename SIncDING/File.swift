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
    
    /* The course to which this file belongs */
    var course: String
    /* The folder where this file is keep */
    var folder: String?
    /* The name of the file, if it's not a folder */
    var name: String?
    /* URL link of this file */
    var link: String
    /* The path of the parent folder of this file */
    var parentPath: String
    /* Defines if a File corresponding to a Folder has been checked or not */
    var checked = false
    /* Defines if the File is currently being downloaded */
    var downloading = false
    
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
    }
    
    // MARK: - Saving

    func download(headers: [String: String], callback: (() -> Void)) {
        guard isFile() else {
            checkFolderStructure()
            callback()
            return
        }
        guard !downloading else {
            return
        }
        guard !exists() else {
            callback()
            return
        }
        downloading = true
        Alamofire.request(.GET, link, headers: headers).response { (_, response, data, error) in
            self.downloading = false
            if error != nil {
                print("Error: \(error!)")
            } else {
//                  Usar esto para ver si actualizar archivos? Muestra fecha actualizacion
//                let resposeHeaders = response?.allHeaderFields
//                print(resposeHeaders)
//                let size = response?.expectedContentLength
//                print("size : \(size)")
                
                self.checkFolderStructure()
                data!.writeToFile(self.path(), atomically: true)
            }
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
        if split?.count > 1 && split?[(split?.count ?? 1) - 1].characters.count < 5 {
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