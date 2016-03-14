//
//  SidingParser.swift
//  SIncDING
//
//  Created by Nicolás Gebauer on 08-03-16.
//  Copyright © 2016 Nicolás Gebauer. All rights reserved.
//

import Foundation
import Alamofire
import Kanna

class SidingParser: NSObject {
    
    // MARK: - Constants
    
    let sidingLogin = "https://intrawww.ing.puc.cl/siding/index.phtml"
    let sidingDomain = "intrawww.ing.puc.cl"
    let sidingSite = "https://intrawww.ing.puc.cl/siding/dirdes/ingcursos/cursos/vista.phtml"
    
    // MARK: - Variables
    
    var delegate: SidingParserDelegate?
    var username: String
    var password: String
    var path: String
    var cookies: [NSHTTPCookie] = []
    var files: [File] = []
    
    // MARK: - Init
    
    init(username: String, password: String, path: String) {
        self.username = username
        self.password = password
        self.path = path
    }
    
    // MARK: - Main
    
    func login() {
        let params: [String: String] = [
            "login": username,
            "passwd": password,
            "sw": "",
            "sh": "",
            "cd": ""
        ]
        Alamofire.request(.POST, sidingLogin, parameters: params,
            encoding: .URL)
            .response { (_, response, data, error) in
                if error != nil {
                    print("Error: \(error!)")
                } else {
                    let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(response!.allHeaderFields as! [String: String], forURL: NSURL(string: self.sidingDomain)!)
                    self.cookies.appendContentsOf(cookies)
                    self.generateIndex()
                }
        }
    }
    
    func generateIndex(path: String? = nil) {
        self.path = path ?? self.path
        files.removeAll()
        guard headers() != [:] else {
            login()
            return
        }
        checkCourses()
    }
    
    func getData(link: String, filter: String..., checkData: (elements: [XMLElement]) -> Void) {
        Alamofire.request(.GET, link, headers: headers())
            .response { (_, response, data, error) in
                if error != nil {
                    print("Error: \(error!)")
                } else {
                    let stringData = data != nil ? self.stringFromSidingData(data!) : ""
                    if let doc = Kanna.HTML(html: stringData, encoding: NSUTF8StringEncoding) {
                        let elements = doc.xpath("//a | //link").filter({
                            let href = $0["href"]
                            return href != nil && filter.contains({ href!.containsString($0) })
                        })
                        checkData(elements: elements)
                    }
                }
        }
    }
    
    func checkCourses() {
        getData(sidingSite, filter: "id_curso") { (elements: [XMLElement]) in
            elements.forEach({
                let auxSplit = $0.text!.componentsSeparatedByString("s.")[1]
                let section = auxSplit.substringToIndex(auxSplit.startIndex.successor())
                let split = $0.text!.componentsSeparatedByString(" s.\(section) ")
                let course = split[0] + " " + split[1]
                let link = self.sidingSite.componentsSeparatedByString("vista.phtml")[0] + $0["href"]!
                let file = File(course: course, folder: nil, name: nil, link: link, parentPath: self.path)
                self.discovered(file) {
                    self.checkFolder($0)
                }
            })
        }
    }
    
    func checkFolder(file: File) {
        getData(file.link, filter: "vista.phtml?") { (elements: [XMLElement]) in
            file.checked = true
            elements.forEach({
                let folder = $0.text!
                let link = self.sidingSite.componentsSeparatedByString("vista.phtml")[0] + $0["href"]!
                let file = File(course: file.course, folder: folder, name: nil, link: link, parentPath: file.parentPath)
                self.discovered(file) {
                    self.checkFolderContent($0)
                }
            })
        }
    }
    
    func checkFolderContent(file: File) {
        getData(file.link, filter: "vista.phtml?", "id_archivo") { (elements: [XMLElement]) in
            file.checked = true
            elements.filter({ $0["href"]!.containsString("vista.phtml?") }).forEach({
                let folder = $0.text!
                let link = self.sidingSite.componentsSeparatedByString("vista.phtml")[0] + $0["href"]!
                let file = File(course: file.course, folder: "\(file.folder!)/\(folder)", name: nil, link: link, parentPath: file.parentPath)
                self.discovered(file) {
                    self.checkFolderContent($0)
                }
            })
            elements.filter({ $0["href"]!.containsString("id_archivo") }).forEach({
                let name = $0.text!
                let link = self.sidingSite.componentsSeparatedByString("/siding/dirdes/ingcursos/cursos/vista.phtml")[0] + $0["href"]!
                let file = File(course: file.course, folder: file.folder!, name: name, link: link, parentPath: file.parentPath)
                self.discovered(file)
            })
        }
    }
    
    func discovered(file: File?, newFile: ((file: File) -> Void)? = nil) {
        if let file = file {
            mainQueue({
                if !self.files.contains({ $0.link == file.link }) {
                    self.files.append(file)
                    newFile?(file: file)
                }
            })
        }
        checkIndexTask()
    }
    
    func syncFiles() {
        files.filter({ !$0.synced }).forEach({ $0.download(self.headers(), callback: { self.checkFileSyncTask() }) })
    }
    
    // MARK: - Progress check
    
    func newFiles() -> Int {
        return files.filter({ !$0.exists() }).count
    }
    
    func checkIndexTask() {
        delegate?.indexedFiles(files.filter({ $0.checked }).count, total: files.count, new: newFiles())
    }
    
    func checkFileSyncTask() {
        delegate?.syncedFiles(files.filter({ $0.synced }).count, total: files.count)
    }
    
    // MARK: - Helpers
    
    func headers() -> [String: String] {
        return NSHTTPCookie.requestHeaderFieldsWithCookies(cookies)
    }
    
    func stringFromSidingData(data: NSData) -> String {
        let str = String(data: data, encoding: NSASCIIStringEncoding)!
        return str
    }
    
    // MARK: - Log
    
    func log(devLog: Bool) -> String {
        var log = "Archivos nuevos: \(newFiles())\n"
        log += "Archivos totales: \(files.count)\n"
        let filesNew = files.filter({ !$0.exists() })
        let filesSynced = files.filter({ $0.exists() })
        let sort: (file1: File, file2: File) -> Bool = { $1.course > $0.course }
        for file in filesNew.sort(sort) + filesSynced.sort(sort) {
            log += "\(!file.exists() ? "- (Nuevo!) " : "")--- Encontrado:\n\tCurso: \(file.course)\n"
            if file.folder != nil {
                log += "\tCarpeta: \(file.folder!)\n"
                if file.name != nil {
                    log += "\tArchivo: \(file.name!)\n"
                }
            }
            if devLog {
                log += "\tLink: \(file.link)\n"
            }
        }
        return log
    }
}