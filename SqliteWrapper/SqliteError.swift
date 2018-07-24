//
//  SqliteError.swift
//  SqliteWrapper
//
//  Created by Rayhan Janam on 10/20/17.
//  Copyright © 2017 Rayhan Janam. All rights reserved.
//

import Foundation


public enum SqliteError : Error {
    case OpenDatabaseError(message: String)
    case PurgeDatabaseError(message: String)
    case PrepareError(message: String)
    case BindError(message: String)
    case StepError(message: String)
}
