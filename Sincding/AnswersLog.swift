//
//  Answers.swift
//  Sincding
//
//  Created by Nicolás Gebauer on 14-07-16.
//  Copyright © 2016 Nicolás Gebauer. All rights reserved.
//

import Crashlytics

struct AnswersLog {
    
    static func log(event: String, attributes: [String: AnyObject]?) {
        #if RELEASE
            Answers.logCustomEventWithName(event, customAttributes: attributes)
        #endif
    }
}