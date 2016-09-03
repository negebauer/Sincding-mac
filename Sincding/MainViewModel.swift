//
//  MainViewModel.swift
//  Sincding
//
//  Created by Nicolás Gebauer on 13-07-16.
//  Copyright © 2016 Nicolás Gebauer. All rights reserved.
//

import UCSiding
import Crashlytics

protocol MainViewModelDelegate: class {
    func connecting()
    func cancelIndexing()
    func cancelSync()
    func loginError()
    func indexedFiles(checked: Int, total: Int, newFiles: Int, newFolders: Int)
    func syncedFiles(synced: Int, total: Int)
}

class MainViewModel: UCSCoursesDelegate {
    
    // MARK: - Constants

    // MARK: - Variables
    
    var session: UCSSession?
    var courses: UCSCourses?
    var files: [File] = []
    var filesToDownload: [File] = []
    var path: String = ""
    
    weak var delegate: MainViewModelDelegate?
    private var isUserSet = false
    
    // MARK: - Files
    
    func generateIndex(username: String, password: String, path: String) {
        cancelIndexing()
        delegate?.connecting()
        AnswersLog.log("Index", attributes: nil)
        if path.substringFromIndex(path.endIndex) == "/" {
            self.path = path.substringToIndex(path.endIndex)
        } else {
            self.path = path
        }
        newSession(username, password: password)
        if let session = session {
        session.login({
            self.generateIndex(session)
            }, failure: { error in
                self.delegate?.loginError()
        })
        }
    }
    
    private func generateIndex(session: UCSSession) {
        files.removeAll()
        courses = UCSCourses(session: session, delegate: self)
        courses?.loadCourses()
    }
    
    private func cancelIndexing() {
        session = nil
        courses = nil
        files.removeAll()
        cancelDownloads()
        delegate?.cancelIndexing()
    }
    
    func isIndexGenerated() -> Bool {
        return courses != nil
    }
    
    func isDownloadNeeded() -> Bool {
        return newFilesCount() > 0
    }
    
    func syncFiles() {
        cancelDownloads()
        guard let headers = session?.headers() else { return }
        AnswersLog.log("Sync", attributes: ["Files": newFilesCount(), "Folders": newFoldersCount()])
        filesToDownload = files.filter({ !$0.downloaded }).sort({ f1, f2 in f1.isFolder() })
        print(filesToDownload[0].isFolder())
        filesToDownload.forEach({ $0.download(headers, callback: { self.updateSyncedFilesCount() }) })
    }
    
    private func cancelDownloads() {
        delegate?.cancelSync()
        filesToDownload.forEach({ $0.cancelDownload() })
        filesToDownload.removeAll()
    }
    
    func updateSyncedFilesCount() {
        delegate?.syncedFiles(filesToDownload.filter({ $0.downloaded }).count, total: filesToDownload.count)
    }
    
    func newFilesCount() -> Int {
        return files.filter({ !$0.downloaded && $0.isFile() }).count
    }
    
    func newFoldersCount() -> Int {
        return files.filter({ !$0.downloaded && $0.isFolder() }).count
            + (courses?.courses.filter({ File.fileExists(path + $0.pathForChildren()) }).count ?? 0)
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
    
    func generateLog() -> String {
        var log = ""
        courses?.courses.forEach({ course in
            log += "- " + course.name + "\n\n"
            course.files.forEach({ file in
                let file = File(sidingFile: file, sincdingFolderPath: self.path)
                log += file.downloaded ? "" : "##### "
                log += file.isFile() ? "(A) " : "(C) "
                log += file.name + "\n"
            })
            log += "\n\n"
        })
        return log
    }
    
    // MARK: - UCSCoursesDelegate
    
    func coursesFound(ucsCourses: UCSCourses, courses: [UCSCourse]) {
        // FIX: Can't download folder if empty
        self.courses?.loadCoursesFiles()
    }
    
    func courseFoundFile(ucsCourses: UCSCourses, courses: [UCSCourse], course: UCSCourse, file: UCSFile) {
        let newFile = File(sidingFile: file, sincdingFolderPath: path)
        files.append(newFile)
        delegate?.indexedFiles(ucsCourses.numberOfCheckedFiles(), total: ucsCourses.numberOfFiles(), newFiles: newFilesCount(), newFolders: newFoldersCount())
        if let headers = session?.headers() where Settings.downloadOnIndex && !newFile.downloaded {
            filesToDownload.append(newFile)
            newFile.download(headers, callback: { self.updateSyncedFilesCount() })
        }
    }

}