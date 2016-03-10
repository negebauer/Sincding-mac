//
//  ViewController.swift
//  SIncDING
//
//  Created by Nicolás Gebauer on 08-03-16.
//  Copyright © 2016 Nicolás Gebauer. All rights reserved.
//

import Cocoa
import Crashlytics
import KeychainAccess

class ViewController: NSViewController, NSTextFieldDelegate {
    
    // MARK: - Enums
    
    enum DataKeys: String {
        case SaveData, Username, Password, Path
        
        static func array() -> [DataKeys] {
            return [SaveData, Username, Password, Path]
        }
    }
    
    // MARK: - Constants
    
    let workingText = "Trabajando..."
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let keychain = Keychain(service: "com.negebauer.SIncDING")
    
    // MARK: - Variables
    
    var sidingParser: SidingParser!
    var filesReferenced = false
    
    // MARK: - Outlets
    
    @IBOutlet weak var usernameField: NSTextField!
    @IBOutlet weak var passwordField: NSSecureTextField!
    @IBOutlet weak var path: NSTextField!
    @IBOutlet weak var buttonIndex: NSButton!
    @IBOutlet weak var buttonDownload: NSButton!
    @IBOutlet weak var saveData: NSButton!
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        path.stringValue = ""
        
        if userDefaults.boolForKey(DataKeys.SaveData.rawValue) {
            saveData.state = NSOnState
            if let username = userDefaults.stringForKey(DataKeys.Username.rawValue) {
                usernameField.stringValue = username
            }
            let password = try? keychain.getString(DataKeys.Password.rawValue)
            if password != nil {
                passwordField.stringValue = password!!
            }
            if let path = userDefaults.stringForKey(DataKeys.Path.rawValue) {
                self.path.stringValue = path
            }
        } else {
            saveData.state = NSOffState
        }
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
        if saveData.state == NSOnState {
            userDefaults.setValue(true, forKey: DataKeys.SaveData.rawValue)
            userDefaults.setValue(usernameField.stringValue, forKey: DataKeys.Username.rawValue)
            let _ = try? keychain.set(passwordField.stringValue, key: DataKeys.Password.rawValue)
            userDefaults.setValue(path.stringValue, forKey: DataKeys.Path.rawValue)
        } else {
            userDefaults.setValue(false, forKey: DataKeys.SaveData.rawValue)
            let _ = try? keychain.set("", key: DataKeys.Password.rawValue)
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
    
    @IBAction func enterPressed(sender: AnyObject) {
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

