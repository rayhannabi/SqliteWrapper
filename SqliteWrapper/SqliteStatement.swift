//
//  SqliteStatement.swift
//  SqliteWrapper
//
//  Created by Rayhan Janam on 10/20/17.
//  Copyright © 2017 Rayhan Janam. All rights reserved.
//

import Foundation
import SQLite3

public class SqliteStatement {
    private let _statementPointer: OpaquePointer?
    
    public var statementPointer: OpaquePointer? {
        return _statementPointer
    }
    
    init(preparedStatement pointer: OpaquePointer?) {
        self._statementPointer = pointer
    }
}

extension SqliteStatement {
    public func bindInt(atSequence sequence: Int, withValue value: Int) throws {
        if _statementPointer != nil {
            sqlite3_bind_int(_statementPointer, Int32(sequence), Int32(value))
        } else {
            throw SqliteError
                .BindError(message: "Sql parameter binding of \(value) at \(sequence) failed")
        }
    }
    
    public func bindString(atSequence sequence: Int, withValue value: String) throws {
        let stringValue = NSString(string: value)
        
        if _statementPointer != nil {
            sqlite3_bind_text(_statementPointer, Int32(sequence),
                             stringValue.utf8String, -1, nil)
        } else {
            throw SqliteError
                .BindError(message: "Sql parameter binding of \(value) at \(sequence) failed")
        }
    }
}

extension SqliteStatement {
    public func getColumnInt(atIndex index: Int) -> Int {
        let value = sqlite3_column_int(_statementPointer, Int32(index))
        
        return Int(value)
    }
    
    public func getColumnString(atIndex index: Int) -> String {
        let value = sqlite3_column_text(_statementPointer, Int32(index))
        
        return String(cString: value!)
    }
}














