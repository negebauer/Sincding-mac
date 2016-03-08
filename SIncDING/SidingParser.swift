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

class SidingParser {
    
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
                    self.parseSiteHTML(String(data: data!, encoding: NSASCIIStringEncoding)!)
                }
        }
    }
    
    func parseSiteHTML(data: String) {
        if let doc = Kanna.HTML(html: data, encoding: NSUTF8StringEncoding) {
            print(doc.title)
            // Search for nodes by XPath
            for link in doc.xpath("//a | //link") {
                print(link.text)
                print(link["href"])
            }
            
            Alamofire.request(.GET, sidingSite + "?accion_curso=avisos&acc_aviso=mostrar&id_curso_ic=8036", headers: headers())
                .response { (_, response, data, error) in
                    if error != nil {
                        print("Error: \(error!)")
                    } else {
                        print("Response: \(response)")
                    }
            }
            
        }
    }
}