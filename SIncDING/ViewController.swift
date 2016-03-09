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
    
    let workingText = "Trabajando..."
    
    // MARK: - Variables
    
    var sidingParser: SidingParser!
    var filesReferenced = false
    
    // MARK: - Outlets
    
    @IBOutlet weak var usernameField: NSTextField!
    @IBOutlet weak var passwordField: NSSecureTextField!
    @IBOutlet weak var path: NSTextField!
    @IBOutlet weak var buttonIndex: NSButton!
    @IBOutlet weak var buttonDownload: NSButton!
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        path.stringValue = ""
//        usernameField.stringValue = "negebauer"
//        path.stringValue = "/Users/Nico/Downloads/TEST"
//        passwordField.stringValue = ""
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
        }
        sidingParser = SidingParser(username: usernameField.stringValue, password: passwordField.stringValue, path: path.stringValue)
        sidingParser.viewController = self
        buttonIndex.title = workingText
        sidingParser.doStuff()
    }
    
    @IBAction func downloadAndSave(sender: AnyObject) {
        guard sidingParser != nil else {
            let alert = NSAlert()
            alert.addButtonWithTitle("Ok, sorry")
            alert.messageText = "Primero genera el index po"
            alert.informativeText = "Como queri que funcione sin eso..."
            alert.alertStyle = .WarningAlertStyle
            alert.runModal()
            return
        }
        buttonDownload.title = workingText
        sidingParser.downloadAndSaveFiles()
    }
    
    @IBAction func passwordEnterPressed(sender: AnyObject) {
        doStuff(sender)
    }
    
    @IBAction func showLog(sender: AnyObject) {
        performSegueWithIdentifier("IDShowLog", sender: self)
    }
    
    // MARK: - Functions
    
    func fileReferencesReady() {
        buttonIndex.title = "Index listo!"
    }
    
    func fileProccessReady() {
        buttonDownload.title = "Archivos sincronizados"
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "IDShowLog" {
            let logView = segue.destinationController as! LogViewController
            logView.log = sidingParser.log
        }
    }
    
}

