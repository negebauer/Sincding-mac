//
//  MainViewModel.swift
//  SIncDING
//
//  Created by Nicolás Gebauer on 13-07-16.
//  Copyright © 2016 Nicolás Gebauer. All rights reserved.
//

import UCSiding
import Crashlytics

protocol MainViewModelDelegate {
    func indexedFiles(checked: Int, total: Int, new: Int)
    func syncedFiles(synced: Int, total: Int)
}

extension MainViewModelDelegate {
//    TODO: Placeholder MainViewModelDelegate functions
    func indexedFiles(checked: Int, total: Int, new: Int) {}
    func syncedFiles(synced: Int, total: Int) {}
}

class MainViewModel {
    
    // MARK: - Constants

    // MARK: - Variables
    
    var session: UCSSession?
    var path: String = ""
    
    var delegate: MainViewModelDelegate?
    private var isUserSet = false
    
    // MARK: - Files
    
    func generateIndex(username: String, password: String, path: String) {
        Answers.logCustomEventWithName("Index", customAttributes: nil)
        newSession(username, password: password)
        self.path = path
    }
    
    func isIndexGenerated() -> Bool {
        //        TODO: Actually consult for the index against UCSCourses
        return false
    }
    
    func isDownloadNeeded() -> Bool {
        //        TODO: Actually consult for the against UCSCourses
        return false
    }
    
    func syncFiles() {
        //        TODO: Get number of new files
        Answers.logCustomEventWithName("Sync", customAttributes: ["Files": 2])
        //        TODO: Actually sync files
    }
    
    // MARK: - Session
    
    func newSession(username: String, password: String) {
        setUser(username)
        session = UCSSession(username: username, password: password)
    }
    
    func logged() -> Bool {
        return session != nil
    }
    
    // MARK: - General
    
    func setUser(username: String) {
        guard !isUserSet else { return }
        Crashlytics.sharedInstance().setUserIdentifier(username)
        Crashlytics.sharedInstance().setUserEmail(username + "@uc.cl")
        isUserSet = true
    }

}