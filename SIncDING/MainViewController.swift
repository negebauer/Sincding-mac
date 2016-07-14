//
//  ViewController.swift
//  SIncDING
//
//  Created by Nicolás Gebauer on 08-03-16.
//  Copyright © 2016 Nicolás Gebauer. All rights reserved.
//

import Cocoa
import Crashlytics

class MainViewController: NSViewController, NSTextFieldDelegate, SidingParserDelegate {
    
    // MARK: - Constants
    
    // MARK: - Variables
    
    var sidingParser: SidingParser!
    var filesReferenced = false
    weak var logView: LogViewController?
    var isUserSet = false
    
    var model: MainViewModel = MainViewModel()
    
    // MARK: - Outlets
    
    @IBOutlet weak var usernameField: NSTextField!
    @IBOutlet weak var passwordField: NSSecureTextField!
    @IBOutlet weak var path: NSTextField!
    @IBOutlet weak var buttonIndex: NSButton!
    @IBOutlet weak var buttonDownload: NSButton!
    @IBOutlet weak var saveData: NSButton!
    @IBOutlet weak var syncAtIndex: NSButton!
    @IBOutlet weak var indexLabel: NSTextField!
    @IBOutlet weak var syncLabel: NSTextField!
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        path.stringValue = ""
        loadSettings()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.title = "SIncDING"
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
            if !isUserSet {
                setUser(usernameField.stringValue)
            }
            sidingParser = SidingParser(username: usernameField.stringValue, password: passwordField.stringValue, path: path.stringValue)
            sidingParser.delegate = self
        }
        Answers.logCustomEventWithName("Index", customAttributes: nil)
        saveSettings()
        sidingParser.generateIndex(path.stringValue)
    }
    
    @IBAction func syncFiles(sender: AnyObject) {
        guard sidingParser != nil else {
            showMissingDataAlert("Primero genera el index po")
            return
        }
        let newFiles = sidingParser.newFiles()
        guard newFiles > 0 else {
            syncLabel.stringValue = "No hay nuevos archivos que descargar"
            return
        }
        Answers.logCustomEventWithName("Sync", customAttributes: ["Files": newFiles])
        sidingParser.syncFiles()
    }
    
    @IBAction func enterPressed(sender: AnyObject) {
        generateIndex(sender)
    }
    
    @IBAction func saveSettingsPush(sender: AnyObject) {
        saveSettings()
    }
    
    @IBAction func chooseFolder(sender: AnyObject) {
        let chooseFolder = NSOpenPanel()
        chooseFolder.canChooseFiles = false
        chooseFolder.canChooseDirectories = true
        chooseFolder.allowsMultipleSelection = false
        chooseFolder.prompt = "Seleccionar carpeta"
        if chooseFolder.runModal() == NSModalResponseOK {
            let file = chooseFolder.URLs[0]
            path.stringValue = file.path ?? "Error cargando la ruta, intentalo de nuevo"
            saveSettings()
        }
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
    
    // MARK: - Settings management
    
    func loadSettings() {
        guard Settings.configured else {
            saveData.state = true.nsState()
            return
        }
        let load = Settings.saveData
        saveData.state = load.nsState()
        if load {
            usernameField.stringValue = Settings.username ?? ""
            passwordField.stringValue = Settings.password ?? ""
            path.stringValue = Settings.path ?? ""
        }
        syncAtIndex.state = Settings.downloadOnIndex.nsState()
    }
    
    func saveSettings() {
        let save = saveData.state == NSOnState
        Settings.saveData = save
        if save {
            Settings.username = usernameField.stringValue
            Settings.password = passwordField.stringValue
            Settings.path = path.stringValue
        } else {
            Settings.deleteData()
        }
        Settings.downloadOnIndex = syncAtIndex.state == NSOnState
    }
    
    // MARK: - SidingParserDelegate methods
    
    func indexedFiles(checked: Int, total: Int, new: Int) {
        indexLabel.stringValue = "Indexados \(checked)/\(total)\t\(new) nuevos archivos/carpetas"
        if syncAtIndex.state == NSOnState {
            syncFiles(checked)
        }
    }
    
    func syncedFiles(synced: Int, total: Int) {
        if synced == total {
            syncLabel.stringValue = "Descarga finalizada"
        } else {
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

