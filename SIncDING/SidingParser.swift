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
    var cookies: [NSHTTPCookie] = []
    
    // MARK: - Init
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
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
                    self.parseSiteHTML(self.stringFromSidingData(data!))
                }
        }
    }
    
    func parseSiteHTML(data: String) {
        if let doc = Kanna.HTML(html: data, encoding: NSUTF8StringEncoding) {
            print(doc.title)

//            for link in doc.xpath("//a | //link") {
//                print(link.text)
//                print(link["href"])
//            }
            print("Headers: \(headers())")
            Alamofire.request(.GET, "https://intrawww.ing.puc.cl/siding/dirdes/ingcursos/cursos/vista.phtml?accion_curso=avisos&acc_aviso=mostrar&id_curso_ic=8019", headers: headers())
                .response { (_, response, data, error) in
                    if error != nil {
                        print("Error: \(error!)")
                    } else {
                        // print("Response: \(self.stringFromSidingData(data!))")
                        let doc = Kanna.HTML(html: self.stringFromSidingData(data!), encoding: NSUTF8StringEncoding)
//                        print("Doc: \(doc!.text!)")
//                        for link in doc!.xpath("//a | //link") {
//                                            print(link.text)
//                                            print(link["href"])
//                                        }
                    }
            }
            Alamofire.request(.GET, "https://intrawww.ing.puc.cl/siding/dirdes/ingcursos/cursos/vista.phtml?accion_curso=carpetas&acc_carp=abrir_carpeta&id_curso_ic=8019&id_carpeta=48167", headers: headers())
                .response { (_, response, data, error) in
                    if error != nil {
                        print("Error: \(error!)")
                    } else {
                        // print("Response: \(self.stringFromSidingData(data!))")
                        let doc = Kanna.HTML(html: self.stringFromSidingData(data!), encoding: NSUTF8StringEncoding)
//                        print("Doc: \(doc!.text!)")
//                        for link in doc!.xpath("//a | //link") {
//                            print(link.text)
//                            print(link["href"])
//                        }
                    }
            }
            Alamofire.request(.GET, "https://intrawww.ing.puc.cl/siding/dirdes/ingcursos/cursos/descarga.phtml?id_curso_ic=8019&id_archivo=304266", headers: headers())
                .response { (_, response, data, error) in
                    if error != nil {
                        print("Error: \(error!)")
                    } else {
                        
                        //Get the local docs directory and append your local filename.
                        var docURL = (NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)).last! as NSURL
                        
                        docURL = docURL.URLByAppendingPathComponent( "myFileName.pdf")
                        
                        //Lastly, write your file to the disk.
                        data!.writeToURL(docURL, atomically: true)
                        
                        // print("Response: \(self.stringFromSidingData(data!))")
//                        let doc = Kanna.HTML(html: self.stringFromSidingData(data!), encoding: NSUTF8StringEncoding)
//                        print("Doc: \(doc!.text!)")
//                        for link in doc!.xpath("//a | //link") {
//                            print(link.text)
//                            print(link["href"])
//                        }
                    }
            }
        }
    }
}