//
//  Database.swift
//  imessage-wrapped
//
//  Created by Tommy Lam on 7/5/23.
//

import Foundation
import SQLite


class Database {
    static let shared = Database()
    let db: Connection?
    var dbPath: URL
    
    init() {
        if (!development) {
            func realHomeDirectory() -> URL? {
                guard let pw = getpwuid(getuid()) else { return nil }
                return URL(fileURLWithFileSystemRepresentation: pw.pointee.pw_dir, isDirectory: true, relativeTo: nil)
            }
            guard let url = realHomeDirectory() else {
                fatalError("Unable to get users home directory.")
            }
            dbPath = url.appendingPathComponent("/Library/Messages/chat.db")
        } else {
            guard let url = Bundle.main.url(forResource: "chat", withExtension: "db") else {
                fatalError("Unable to find database file.")
            }
            dbPath = url
        }
        do {
            db = try Connection(dbPath.absoluteString)
        } catch let error {
            print(error.localizedDescription)
            fatalError("Unable to make connection to database")
        }
    }
    
    public func printDbPath() {
        print(dbPath)
    }
}
