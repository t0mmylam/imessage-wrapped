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
    let db: Connection
    var dbPath: URL
    
    // Define the table object
    let chat = Table("chat")

    // Define the column expression
    let chatIdentifier = Expression<String>("chat_identifier")
    
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
    
    public func getContactMessageCount(number: String) -> String {
        let rawQuery = """
            SELECT COUNT(chat.chat_identifier) AS message_count
            FROM chat
            JOIN chat_message_join ON chat.ROWID = chat_message_join.chat_id
            JOIN message ON chat_message_join.message_id = message.ROWID
            WHERE chat.chat_identifier = '\(number)'
            GROUP BY chat.chat_identifier;
            """

        do {
            for row in try db.prepare(rawQuery) {
                if let count = row[0] as? Int64 {
                    // print(String(count))
                    return String(count)
                }
            }
        } catch {
            print("Query error: \(error)")
        }
        return ""
    }
    
    public func getContactSentMessageCount(number: String) -> String {
        let rawQuery = """
            SELECT COUNT(chat.chat_identifier) AS message_count
            FROM chat
            JOIN chat_message_join ON chat.ROWID = chat_message_join.chat_id
            JOIN message ON chat_message_join.message_id = message.ROWID
            WHERE chat.chat_identifier = '\(number)'
            AND message.is_from_me = 1
            GROUP BY chat.chat_identifier;
            """

        do {
            for row in try db.prepare(rawQuery) {
                if let count = row[0] as? Int64 {
                    // print(String(count))
                    return String(count)
                }
            }
        } catch {
            print("Query error: \(error)")
        }
        return ""
    }
    
    public func getContactReceivedMessageCount(number: String) -> String {
        let rawQuery = """
            SELECT COUNT(chat.chat_identifier) AS message_count
            FROM chat
            JOIN chat_message_join ON chat.ROWID = chat_message_join.chat_id
            JOIN message ON chat_message_join.message_id = message.ROWID
            WHERE chat.chat_identifier = '\(number)'
            AND message.is_from_me = 0
            GROUP BY chat.chat_identifier;
            """

        do {
            for row in try db.prepare(rawQuery) {
                if let count = row[0] as? Int64 {
                    // print(String(count))
                    return String(count)
                }
            }
        } catch {
            print("Query error: \(error)")
        }
        return ""
    }
    
    public func getContactLateMessageCount(number: String) -> String {
        let rawQuery = """
            SELECT COUNT(chat.chat_identifier) AS message_count
            FROM chat
            JOIN chat_message_join ON chat.ROWID = chat_message_join.chat_id
            JOIN message ON chat_message_join.message_id = message.ROWID
            WHERE chat.chat_identifier = '\(number)'
            GROUP BY chat.chat_identifier;
            """

        do {
            for row in try db.prepare(rawQuery) {
                if let count = row[0] as? Int64 {
                    // print(String(count))
                    return String(count)
                }
            }
        } catch {
            print("Query error: \(error)")
        }
        return ""
    }
}
