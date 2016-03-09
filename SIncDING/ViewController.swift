//
//  ViewController.swift
//  SIncDING
//
//  Created by Nicolás Gebauer on 08-03-16.
//  Copyright © 2016 Nicolás Gebauer. All rights reserved.
//

import Cocoa
import Crashlytics

class ViewController: NSViewController, NSTextFieldDelegate {
    
    // MARK: - Constants
    
    // MARK: - Variables
    
    var sidingParser: SidingParser!
    
    // MARK: - Outlets
    
    @IBOutlet weak var usernameField: NSTextField!
    @IBOutlet weak var passwordField: NSSecureTextField!
    @IBOutlet weak var ruta: NSTextField!
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameField.stringValue = "negebauer"
        ruta.stringValue = "/Users/Nico/Dropbox/PUC/01 Cursos/2016-1/"
        passwordField.stringValue = ""
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    // MARK: - Actions
    
    @IBAction func doStuff(sender: AnyObject) {
        if sidingParser == nil {
            guard usernameField.stringValue != "" && passwordField.stringValue != "" else {
                let alert = NSAlert()
                alert.addButtonWithTitle("Ok, sorry")
                alert.messageText = "Pon tu usuario y tu clave po"
                alert.informativeText = "Como queri que funcione sin eso..."
                alert.alertStyle = .WarningAlertStyle
                alert.runModal()
                return
            }
            sidingParser = SidingParser(username: usernameField.stringValue, password: passwordField.stringValue, ruta: ruta.stringValue)
        }
        sidingParser.doStuff()
    }
    
    @IBAction func passwordEnterPressed(sender: AnyObject) {
        doStuff(sender)
    }
    
    // MARK: - Functions
    
    
}

