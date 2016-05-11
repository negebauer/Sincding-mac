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

class ViewController: NSViewController, NSTextFieldDelegate, SidingParserDelegate {
    
    // MARK: - Enums
    
    enum DataKeys: String {
        case SaveData, Username, Password, Path
        
        static func array() -> [DataKeys] {
            return [SaveData, Username, Password, Path]
        }
    }
    
    // MARK: - Constants
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let keychain = Keychain(service: "com.negebauer.SIncDING")
    
    // MARK: - Variables
    
    var sidingParser: SidingParser!
    var filesReferenced = false
    weak var logView: LogViewController?
    
    // MARK: - Outlets
    
    @IBOutlet weak var usernameField: NSTextField!
    @IBOutlet weak var passwordField: NSSecureTextField!
    @IBOutlet weak var path: NSTextField!
    @IBOutlet weak var buttonIndex: NSButton!
    @IBOutlet weak var buttonDownload: NSButton!
    @IBOutlet weak var saveData: NSButton!
    @IBOutlet weak var indexLabel: NSTextField!
    @IBOutlet weak var syncLabel: NSTextField!
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        path.stringValue = ""
        
        let data = userDefaults.dataForKey(DataKeys.SaveData.rawValue)
        if userDefaults.boolForKey(DataKeys.SaveData.rawValue) {
            saveData.state = NSOnState
            if let username = userDefaults.stringForKey(DataKeys.Username.rawValue) {
                usernameField.stringValue = username
            }
            let password = try? keychain.getString(DataKeys.Password.rawValue)
            if password != nil && password! != nil {
                passwordField.stringValue = password!!
            }
            if let path = userDefaults.stringForKey(DataKeys.Path.rawValue) {
                self.path.stringValue = path
            }
        } else if data != nil {
            saveData.state = NSOnState
        } else {
            saveData.state = NSOffState
        }
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    // MARK: - De Init
    
    override func viewDidDisappear() {
        NSApplication.sharedApplication().terminate(nil)
    }
    
    // MARK: - Actions
    
    @IBAction func generateIndex(sender: AnyObject) {
        if sidingParser == nil {
            guard usernameField.stringValue != "" && passwordField.stringValue != "" else {
                showMissingDataAlert("Pon tu usuario y tu clave po")
                return
            }
            sidingParser = SidingParser(username: usernameField.stringValue, password: passwordField.stringValue, path: path.stringValue)
            sidingParser.delegate = self
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
        sidingParser.generateIndex(path.stringValue)
    }
    
    @IBAction func syncFiles(sender: AnyObject) {
        guard sidingParser != nil else {
            showMissingDataAlert("Primero genera el index po")
            return
        }
        guard sidingParser.newFiles() > 0 else {
            syncLabel.stringValue = "No hay nuevos archivos que descargar"
            return
        }
        sidingParser.syncFiles()
    }
    
    @IBAction func enterPressed(sender: AnyObject) {
        generateIndex(sender)
    }
    
    @IBAction func showLog(sender: AnyObject) {
        performSegueWithIdentifier(Segue.ShowLog, sender: false)
    }
    
    @IBAction func showDevLog(sender: AnyObject) {
        performSegueWithIdentifier(Segue.ShowLog, sender: true)
    }
    
    // MARK: - Functions
    
    func showMissingDataAlert(message: String) {
        let alert = NSAlert()
        alert.addButtonWithTitle("Ok, sorry")
        alert.messageText = message
        alert.informativeText = "Como queri que funcione sin eso..."
        alert.alertStyle = .WarningAlertStyle
        alert.runModal()
    }
    
    // MARK: - SidingParserDelegate methods
    
    func indexedFiles(checked: Int, total: Int, new: Int) {
        indexLabel.stringValue = "Indexados \(checked)/\(total)\t\(new) nuevos archivos/carpetas"
    }
    
    func syncedFiles(synced: Int, total: Int) {
        if synced == total {
            syncLabel.stringValue = "Descarga finalizada"
        }
        else {
            syncLabel.stringValue = "Descargados \(synced)/\(total)"
        }
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "IDShowLog" {
            logView?.view.window?.close()
            logView = segue.destinationController as? LogViewController
            let devLog = sender as? Bool
            guard sidingParser != nil else {
                logView?.log = "Primero haz el index"
                return
            }
            logView?.log = sidingParser.log(devLog ?? false)
        }
    }
    
}

