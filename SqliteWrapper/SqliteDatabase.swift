//
//  SqliteDatabase.swift
//  SqliteWrapper
//
//  Created by Rayhan Janam on 10/20/17.
//  Copyright © 2017 Rayhan Janam. All rights reserved.
//

import Foundation
import SQLite3

public class SqliteDatabase {
    
    private let _databasePointer: OpaquePointer?
    
    public private(set) var rowObjectCollection: [AnyObject?]
    
    public var errorMessage: String {
        if let errorPointer = sqlite3_errmsg(_databasePointer) {
            return String(cString: errorPointer)
        } else {
            return "UNSPECIFIED Error"
        }
    }
    
    private init(dbPointer: OpaquePointer?) {
        self._databasePointer = dbPointer
        self.rowObjectCollection = [AnyObject?]()
    }
    
    deinit {
        sqlite3_close_v2(_databasePointer)
    }
}

extension SqliteDatabase {
    
    public static func openDatabase(atPath path: String) throws -> SqliteDatabase {
        var dbInstance: OpaquePointer? = nil
        
        if sqlite3_open(path, &dbInstance) == SQLITE_OK {
            return SqliteDatabase(dbPointer: dbInstance)
        } else {
            defer {
                if dbInstance != nil {
                    sqlite3_close_v2(dbInstance)
                }
            }
            
            if let errorPointer = sqlite3_errmsg(dbInstance) {
                let message = String.init(cString: errorPointer)
                throw SqliteError.OpenDatabaseError(message: message)
            } else {
                throw SqliteError.OpenDatabaseError(message: "UNSPECIFIED Error")
            }
        }
    }
    
    public static func purgeDatabase(atPath path: String) throws {
        do {
            if FileManager.default.fileExists(atPath: path) {
                try FileManager.default.removeItem(atPath: path)
            } else {
                throw SqliteError
                    .PurgeDatabaseError(message: "Specified database file was not found")
            }
        } catch {
            throw SqliteError
                .PurgeDatabaseError(message: "Database purging failed")
        }
    }
}

extension SqliteDatabase {
    
    public func prepareStatement(sqlText sql: String) throws -> SqliteStatement {
        var statement: OpaquePointer? = nil
        guard sqlite3_prepare_v2(_databasePointer, sql, -1, &statement, nil) == SQLITE_OK else {
            throw SqliteError.PrepareError(message: errorMessage)
        }
        
        return SqliteStatement(preparedStatement: statement)
    }
    
    public func createTable(createStatement statement: SqliteStatement) throws -> Bool {
        let pointer = statement.statementPointer
        
        if sqlite3_step(pointer) == SQLITE_DONE {
            return true
        } else {
            throw SqliteError.StepError(message: errorMessage)
        }
    }
}

extension SqliteDatabase {
    
    public func execute(preparedStatement statement: SqliteStatement,
                        operationType type: SqliteOperation,
                        columnsForRow columns: () -> AnyObject?) throws {
        switch type {
        case .Insert, .Delete, .Update, .CreateTable:
            let result = runStatement(statement.statementPointer)
            if !result {
                throw SqliteError.StepError(message: errorMessage)
            }
            
        case .Query:
            rowObjectCollection = runQuery(statement.statementPointer,
                                           columns: columns)
        }
    }
    
    private func runStatement(_ pointer: OpaquePointer?) -> Bool {
        if sqlite3_step(pointer) == SQLITE_DONE {
            return true
        } else {
            return false
        }
    }
    
    private func runQuery(_ pointer: OpaquePointer?,
                          columns: () -> AnyObject?) -> [AnyObject?] {
        
        var result = [AnyObject?]()
        while sqlite3_step(pointer) == SQLITE_ROW {
            result.append(columns())
        }
        
        return result
    }
}


























