//
//  MainViewModel.swift
//  Sincding
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

class MainViewModel: UCSCoursesDelegate {
    
    // MARK: - Constants

    // MARK: - Variables
    
    var session: UCSSession?
    var courses: UCSCourses?
    var path: String = ""
    
    var delegate: MainViewModelDelegate?
    private var isUserSet = false
    
    // MARK: - Files
    
    func generateIndex(username: String, password: String, path: String) {
        AnswersLog.log("Index", attributes: nil)
        self.path = path
        newSession(username, password: password)
        if let session = session {
        session.login({
            self.generateIndex(session)
            }, failure: { error in
                // TODO: Notify view
                print(error)
        })
        }
    }
    
    private func generateIndex(session: UCSSession) {
        courses = UCSCourses(session: session, delegate: self)
        courses?.loadCourses()
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
        AnswersLog.log("Sync", attributes: ["Files": 2])
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
    
    // MARK: - UCSCoursesDelegate
    
    func coursesFound(courses: [UCSCourse]) {
        // TODO: Go for files
    }

}