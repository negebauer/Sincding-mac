//
//  Settings.swift
//  SIncDING
//
//  Created by Nicolás Gebauer on 13-07-16.
//  Copyright © 2016 Nicolás Gebauer. All rights reserved.
//

import KeychainAccess

struct Settings {
    
    private enum DataKeys: String {
        case SaveData, DownloadOnIndex, Username, Password, Path
        
        static func array() -> [DataKeys] {
            return [SaveData, DownloadOnIndex, Username, Password, Path]
        }
    }
    
    // MARK: - Constants
    
    static let userDefaults = NSUserDefaults.standardUserDefaults()
    static let keychain = Keychain(service: "com.negebauer.SIncDING")

    // MARK: - Variables
    
    static var username: String? {
        get {
            return userDefaults.stringForKey(DataKeys.Username.rawValue)
        } set {
            userDefaults.setValue(newValue, forKey: DataKeys.Username.rawValue)
        }
    }
    
    static var password: String? {
        get {
            return (try? keychain.getString(DataKeys.Password.rawValue)) ?? nil
        } set {
            let _ = try? keychain.set(newValue ?? "", key: DataKeys.Password.rawValue)
        }
    }
    
    static var path: String? {
        get {
            return userDefaults.stringForKey(DataKeys.Path.rawValue)
        } set {
            userDefaults.setValue(newValue, forKey: DataKeys.Path.rawValue)
        }
    }
    
    static var saveData: Bool {
        get {
            return userDefaults.boolForKey(DataKeys.SaveData.rawValue)
        } set {
            userDefaults.setBool(newValue, forKey: DataKeys.SaveData.rawValue)
        }
    }
    
    static var downloadOnIndex: Bool {
        get {
            return userDefaults.boolForKey(DataKeys.DownloadOnIndex.rawValue)
        } set {
            userDefaults.setBool(newValue, forKey: DataKeys.DownloadOnIndex.rawValue)
        }
    }
    
    static var configured: Bool {
        let saveData = userDefaults.dataForKey(DataKeys.SaveData.rawValue)
        return saveData != nil
    }
    
    // MARK: - Init
    
    init() {
        
    }
    
    // MARK: - Functions

    static func deleteData() {
        username = ""
        password = ""
        path = ""
    }
    
}