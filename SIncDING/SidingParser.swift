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
    
    var username: String
    var password: String
    var ruta: String
    var cookies: [NSHTTPCookie] = []
    
    // MARK: - Init
    
    init(username: String, password: String, ruta: String) {
        self.username = username
        self.password = password
        self.ruta = ruta
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

            var folders: [(String, String)] = []
            
            for link in doc.xpath("//a | //link") {
                let href = link["href"]
                if href!.containsString("id_curso") {
                    let auxSplit = link.text!.componentsSeparatedByString("s.")[1]
                    let section = auxSplit.substringToIndex(auxSplit.startIndex.successor())
                    let split = link.text!.componentsSeparatedByString(" s.\(section) ")
                    let name = split[0] + " " + split[1]
                    let link = sidingSite.componentsSeparatedByString("vista.phtml")[0] + href!
                    // print("Name: \(name)")
                    // print("Link: \(link)")
                    folders.append((name, link))
                }
            }
            
            folders.forEach({
                self.searchFolder($0.0, link: $0.1)
            })
        }
    }
    
    func searchFolder(name: String, link: String) {
        Alamofire.request(.GET, link, headers: headers()).response { (_, response, data, error) in
            if error != nil {
                print("Error: \(error!)")
            } else {
                // print("\n\n\n----- Checkeando \(name)")
                self.checkFolder(name, data: self.stringFromSidingData(data!))
            }
        }
    }
    
    func checkFolder(name: String, data: String) {
        if let doc = Kanna.HTML(html: data, encoding: NSUTF8StringEncoding) {
            
            var subfolders: [(String, String)] = []
            
            for link in doc.xpath("//a | //link") {
                let href = link["href"]
                if href!.containsString("vista.phtml?") {
                    let name = link.text!
                    let link = sidingSite.componentsSeparatedByString("vista.phtml")[0] + href!
                    // print("Name: \(name)")
                    // print("Link: \(link)")
                    subfolders.append((name, link))
                }
            }
            
            subfolders.forEach({
                self.searchSubFolder(name, subfolder: $0.0, link: $0.1)
            })
        }
    }
    
    func searchSubFolder(name: String, subfolder: String, link: String) {
        print("Checkeando curso: \(name), subcarpeta: \(subfolder), con link: \(link)")
    }
}


//            // print("Headers: \(headers())")
//            Alamofire.request(.GET, "https://intrawww.ing.puc.cl/siding/dirdes/ingcursos/cursos/vista.phtml?accion_curso=avisos&acc_aviso=mostrar&id_curso_ic=8019", headers: headers())
//                .response { (_, response, data, error) in
//                    if error != nil {
//                        print("Error: \(error!)")
//                    } else {
//                        // print("Response: \(self.stringFromSidingData(data!))")
//                        let doc = Kanna.HTML(html: self.stringFromSidingData(data!), encoding: NSUTF8StringEncoding)
////                        print("Doc: \(doc!.text!)")
////                        for link in doc!.xpath("//a | //link") {
////                                            print(link.text)
////                                            print(link["href"])
////                                        }
//                    }
//            }
//            Alamofire.request(.GET, "https://intrawww.ing.puc.cl/siding/dirdes/ingcursos/cursos/vista.phtml?accion_curso=carpetas&acc_carp=abrir_carpeta&id_curso_ic=8019&id_carpeta=48167", headers: headers())
//                .response { (_, response, data, error) in
//                    if error != nil {
//                        print("Error: \(error!)")
//                    } else {
//                        // print("Response: \(self.stringFromSidingData(data!))")
//                        let doc = Kanna.HTML(html: self.stringFromSidingData(data!), encoding: NSUTF8StringEncoding)
////                        print("Doc: \(doc!.text!)")
////                        for link in doc!.xpath("//a | //link") {
////                            print(link.text)
////                            print(link["href"])
////                        }
//                    }
//            }
//            Alamofire.request(.GET, "https://intrawww.ing.puc.cl/siding/dirdes/ingcursos/cursos/descarga.phtml?id_curso_ic=8019&id_archivo=304266", headers: headers())
//                .response { (_, response, data, error) in
//                    if error != nil {
//                        print("Error: \(error!)")
//                    } else {
//
//                        //Get the local docs directory and append your local filename.
//                        var docURL = (NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)).last! as NSURL
//
//                        docURL = docURL.URLByAppendingPathComponent( "myFileName.pdf")
//
//                        //Lastly, write your file to the disk.
//                        data!.writeToURL(docURL, atomically: true)
//
//                        // print("Response: \(self.stringFromSidingData(data!))")
////                        let doc = Kanna.HTML(html: self.stringFromSidingData(data!), encoding: NSUTF8StringEncoding)
////                        print("Doc: \(doc!.text!)")
////                        for link in doc!.xpath("//a | //link") {
////                            print(link.text)
////                            print(link["href"])
////                        }
//                    }
//            }
