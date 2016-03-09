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
    
    weak var viewController: ViewController!
    
    var username: String
    var password: String
    var path: String
    var cookies: [NSHTTPCookie] = []
    var files: [File] = []
    var taskCount = 0
    
    // MARK: - Init
    
    init(username: String, password: String, path: String) {
        self.username = username
        self.password = password
        self.path = path
    }
    
    // MARK: - Functions

    func headers() -> [String: String] {
        return NSHTTPCookie.requestHeaderFieldsWithCookies(cookies)
    }
    
    func stringFromSidingData(data: NSData) -> String {
        let str = String(data: data, encoding: NSASCIIStringEncoding)!
        return str
    }
    
    func doStuff() {
        files = []
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
                    self.doStuff2()
                }
        }
    }
    
    func doStuff2() {
        Alamofire.request(.GET, sidingSite, headers: headers())
            .response { (_, response, data, error) in
                if error != nil {
                    print("Error: \(error!)")
                } else {
                    self.lookForFolders(self.stringFromSidingData(data!))
                }
        }
    }
    
    func lookForFolders(data: String) {
        if let doc = Kanna.HTML(html: data, encoding: NSUTF8StringEncoding) {

            var courses: [(String, String)] = []
            
            for link in doc.xpath("//a | //link") {
                let href = link["href"]
                if href!.containsString("id_curso") {
                    let auxSplit = link.text!.componentsSeparatedByString("s.")[1]
                    let section = auxSplit.substringToIndex(auxSplit.startIndex.successor())
                    let split = link.text!.componentsSeparatedByString(" s.\(section) ")
                    let course = split[0] + " " + split[1]
                    let link = sidingSite.componentsSeparatedByString("vista.phtml")[0] + href!
                    // print("Name: \(name)")
                    // print("Link: \(link)")
                    courses.append((course, link))
                }
            }
            
            courses.forEach({
                self.searchFolder($0.0, link: $0.1)
            })
        }
    }
    
    func searchFolder(course: String, link: String) {
        Alamofire.request(.GET, link, headers: headers()).response { (_, response, data, error) in
            if error != nil {
                print("Error: \(error!)")
            } else {
                // print("\n\n\n----- Checkeando \(name)")
                self.checkFolder(course, data: self.stringFromSidingData(data!))
            }
        }
    }
    
    func checkFolder(course: String, data: String) {
        if let doc = Kanna.HTML(html: data, encoding: NSUTF8StringEncoding) {
            
            var folders: [(String, String)] = []
            
            for link in doc.xpath("//a | //link") {
                let href = link["href"]
                if href!.containsString("vista.phtml?") {
                    let folder = link.text!
                    let link = sidingSite.componentsSeparatedByString("vista.phtml")[0] + href!
                    // print("Name: \(name)")
                    // print("Link: \(link)")
                    folders.append((folder, link))
                }
            }
            
            taskCount = folders.count
            
            folders.forEach({
                self.searchSubFolder(course, folder: $0.0, link: $0.1)
            })
        }
    }
    
    func searchSubFolder(course: String, folder: String, link: String) {
        Alamofire.request(.GET, link, headers: headers()).response { (_, response, data, error) in
            if error != nil {
                print("Error: \(error!)")
            } else {
                self.checkFiles(course, folder: folder, data: self.stringFromSidingData(data!))
            }
        }
    }
    
    func checkFiles(course: String, folder: String, data: String) {
        if let doc = Kanna.HTML(html: data, encoding: NSUTF8StringEncoding) {
            
            for link in doc.xpath("//a | //link") {
                let href = link["href"]
                if href!.containsString("id_archivo") {
                    let name = link.text!
                    let link = sidingSite.componentsSeparatedByString("vista.phtml")[0] + href!
                    let file = File(course: course, folder: folder, name: name, link: link)
                    files.append(file)
                }
            }
            
            taskCount--
            checkTaskReady()
        }
    }
    
    func checkTaskReady() {
        if taskCount == 0 {
            viewController.fileReferencesReady()
        }
    }
    
    func downloadAndSaveFiles() {
        files.forEach({ $0.doYourThing(self.path) })
    }
}