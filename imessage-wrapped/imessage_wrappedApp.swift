//
//  imessage_wrappedApp.swift
//  imessage-wrapped
//
//  Created by Tommy Lam on 7/4/23.
//

import SwiftUI
import Contacts

@main
struct imessage_wrappedApp: App {
    func hasFullDiskAccess() -> Bool {
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        let accessURL = homeDirectory.appendingPathComponent("Library/Messages/chat.db")

        do {
            _ = try Data(contentsOf: accessURL)
            return true
        } catch {
            return false
        }
    }
    
    func hasContactsAccess() -> Bool {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        return status == .authorized
    }

    
    var body: some Scene {
        WindowGroup {
            let disk = hasFullDiskAccess()
            let contacts = hasContactsAccess()
            if !disk {
                EnableFullDiskAccessView()
            }
            if !contacts {
                EnableContactsAccessView()
            }
            if disk && contacts {
                ContactsView()
            }
        }
    }
}
