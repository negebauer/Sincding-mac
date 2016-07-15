//
//  File.swift
//  Sincding
//
//  Created by Nicolás Gebauer on 08-03-16.
//  Copyright © 2016 Nicolás Gebauer. All rights reserved.
//

import UCSiding
import Alamofire

class File {
    
    // MARK: - Constants

    let sidingFile: UCSFile
    let parentPath: String
    
    // MARK: - Variables
    
    var name: String { return sidingFile.name }
    var url: String { return sidingFile.url }
    lazy var pathCompleted: String = { return "\(self.parentPath)/\(self.sidingFile.pathCompleted())" }()
    lazy var path: String = { return "\(self.parentPath)/\(self.sidingFile.path)" }()
    
    private var _downloaded: Bool = false
    var downloaded: Bool { return _downloaded }
    private var _downloading: Bool = false
    var downloading: Bool { return _downloading }
    
    private var downloadRequest: Request?
    
    // MARK: - Init
    
    init(sidingFile: UCSFile, sincdingFolderPath: String) {
        self.sidingFile = sidingFile
        self.parentPath = sincdingFolderPath
        _downloaded = fileExists()
    }
    
    // MARK: - Functions

    func checkFolderStructure() {
        if !NSFileManager.defaultManager().fileExistsAtPath(path) {
            let _ = try? NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
        }
    }

    private func fileExists() -> Bool {
        return NSFileManager.defaultManager().fileExistsAtPath(pathCompleted)
    }
    
    static func fileExists(path: String) -> Bool {
        return NSFileManager.defaultManager().fileExistsAtPath(path)
    }
    
    func isFile() -> Bool {
        return sidingFile.isFile()
    }
    
    func isFolder() -> Bool {
        return sidingFile.isFolder()
    }
    
    func download(headers: [String: String], callback: (() -> Void)) {
        guard isFile() else {
            _downloaded = true
            let _ = try? NSFileManager.defaultManager().createDirectoryAtPath(pathCompleted, withIntermediateDirectories: true, attributes: nil)
            callback()
            return
        }
        guard !downloading else {
            return
        }
        guard !downloaded else {
            callback()
            return
        }
        _downloading = true
        downloadRequest = Alamofire.request(.GET, url, headers: headers).response { (_, response, data, error) in
            self.downloadRequest = nil
            self._downloading = false
            guard let data = data where error == nil else { return print("Error: \(error)") }
            self.checkFolderStructure()
            self._downloaded = data.writeToFile(self.pathCompleted, atomically: true)
            callback()
        }
    }
    
    func cancelDownload() {
        downloadRequest?.cancel()
    }
    
}