//
//  LogViewController.swift
//  Sincding
//
//  Created by Nicolás Gebauer on 09-03-16.
//  Copyright © 2016 Nicolás Gebauer. All rights reserved.
//

import Cocoa
import UCSiding

class LogViewController: NSViewController {
    
    // MARK: - Constants

    // MARK: - Variables
    
    var log: String!
    
    // MARK: - Outlets
    
    @IBOutlet var logText: NSTextView!
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logText.editable = false
        guard log != nil else { return logText.string = "Genera el index antes" }
        logText.string = log
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.title = "Log"
    }

    // MARK: - Actions
    
    // MARK: - Functions
    
}