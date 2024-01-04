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
    
    public func getSentMessageCount() -> String {
        let rawQuery = """
            SELECT
               COUNT(*)
            FROM
                chat
                JOIN chat_message_join ON chat. "ROWID" = chat_message_join.chat_id
                JOIN message ON chat_message_join.message_id = message. "ROWID"
            WHERE
                message.is_from_me = 1
            ORDER BY
                message_date ASC;
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
    
    public func getReceivedMessageCount() -> String {
        let rawQuery = """
            SELECT
               COUNT(*)
            FROM
                chat
                JOIN chat_message_join ON chat. "ROWID" = chat_message_join.chat_id
                JOIN message ON chat_message_join.message_id = message. "ROWID"
            WHERE
                message.is_from_me = 0
            ORDER BY
                message_date ASC;
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
                    return String(count)
                }
            }
        } catch {
            print("Query error: \(error)")
        }
        return "0"
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
        return "0"
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
    
    public func getAverageSentCount() -> String {
        let rawQuery = """
            SELECT AVG(texts_sent) AS average_texts_sent_per_day
            FROM (
                SELECT message_date, COUNT(*) AS texts_sent
                FROM (
                    SELECT
                        strftime('%Y-%m-%d', datetime(message.date / 1000000000 + strftime('%s', '2001-01-01'), 'unixepoch', 'localtime')) AS message_date
                    FROM
                        chat
                        JOIN chat_message_join ON chat.ROWID = chat_message_join.chat_id
                        JOIN message ON chat_message_join.message_id = message.ROWID
                    WHERE
                        message.is_from_me = 1
                    GROUP BY
                        message_date, message.ROWID
                ) AS subquery
                GROUP BY
                    message_date
            ) AS subquery_avg;
            """
        do {
            for row in try db.prepare(rawQuery) {
                // print(row)
                if let count = row[0] as? Double {
                    let formattedCount = String(format: "%.3f", count) // Format the decimal value as needed
                    return formattedCount
                }
            }
        } catch {
            print("Query error: \(error)")
        }
        return ""
    }
    
    public func getAverageReceivedCount() -> String {
        let rawQuery = """
            SELECT AVG(texts_received) AS average_texts_received_per_day
            FROM (
                SELECT message_date, COUNT(*) AS texts_received
                FROM (
                    SELECT
                        strftime('%Y-%m-%d', datetime(message.date / 1000000000 + strftime('%s', '2001-01-01'), 'unixepoch', 'localtime')) AS message_date
                    FROM
                        chat
                        JOIN chat_message_join ON chat.ROWID = chat_message_join.chat_id
                        JOIN message ON chat_message_join.message_id = message.ROWID
                    WHERE
                        message.is_from_me = 0
                    GROUP BY
                        message_date, message.ROWID
                ) AS subquery
                GROUP BY
                    message_date
            ) AS subquery_avg;
            """
        do {
            for row in try db.prepare(rawQuery) {
                // print(row)
                if let count = row[0] as? Double {
                    let formattedCount = String(format: "%.3f", count) // Format the decimal value as needed
                    return formattedCount
                }
            }
        } catch {
            print("Query error: \(error)")
        }
        return ""
    }
    
    public func getWordMap() -> [String: Int] {
        var map: [String: Int] = [:]
        let rawQuery = """
            SELECT
                message.text
            FROM
                chat
                JOIN chat_message_join ON chat. "ROWID" = chat_message_join.chat_id
                JOIN message ON chat_message_join.message_id = message. "ROWID"
            ORDER BY
                message_date ASC;
            """
        
        do {
            for row in try db.prepare(rawQuery) {
                // print(row)
                if let sentence = row[0] as? String {
                    let words = sentence.components(separatedBy: CharacterSet.whitespacesAndNewlines)
                    for word in words {
                        if !word.isEmpty {
                            map[word, default: 0] += 1
                        }
                    }
                }
            }
        } catch {
            print("Query error: \(error)")
        }
        // print(map)
        return map
    }
    
    public func getTextMap() -> [String: Int] {
        var map: [String: Int] = [:]
        let rawQuery = """
            SELECT
                message.text
            FROM
                chat
                JOIN chat_message_join ON chat. "ROWID" = chat_message_join.chat_id
                JOIN message ON chat_message_join.message_id = message. "ROWID"
            ORDER BY
                message_date ASC;
            """
        
        do {
            for row in try db.prepare(rawQuery) {
                if let text = row[0] as? String {
                    if text != "" {
                        map[text, default: 0] += 1
                    }
                }
            }
        } catch {
            print("Query error: \(error)")
        }
        return map
    }
    
    public func getMonthCounts() -> [String] {
        var months: [String] = []
        let rawQuery = """
                SELECT
                    strftime('%m', datetime(message.date/1000000000 + strftime("%m", "2001-01-01") ,"unixepoch","localtime")) as month,
                    COUNT(message.text)
                FROM
                    chat
                    JOIN chat_message_join ON chat. "ROWID" = chat_message_join.chat_id
                    JOIN message ON chat_message_join.message_id = message. "ROWID"
                GROUP BY
                    month;
                ORDER BY
                    month;
                """
        do {
            for row in try db.prepare(rawQuery) {
                if let count = row[1] as? Int64 {
                    months.append(String(count))
                }
            }
        } catch {
            print("Query error: \(error)")
        }
        return months
    }
}
