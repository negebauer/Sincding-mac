//
//  MainViewModel.swift
//  SIncDING
//
//  Created by Nicolás Gebauer on 13-07-16.
//  Copyright © 2016 Nicolás Gebauer. All rights reserved.
//

import UCSiding

class MainViewModel {
    
    // MARK: - Constants

    // MARK: - Variables
    
    var session: UCSSession?
    
    // MARK: - Init
    
    init() {
        
    }
    
    // MARK: - Session
    
    func logged() -> Bool {
        return session != nil
    }

}