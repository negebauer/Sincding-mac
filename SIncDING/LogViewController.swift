//
//  LogViewController.swift
//  SIncDING
//
//  Created by Nicolás Gebauer on 09-03-16.
//  Copyright © 2016 Nicolás Gebauer. All rights reserved.
//

import Cocoa

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
        logText.string = log
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }

    // MARK: - Actions
    
    // MARK: - Functions
    
}