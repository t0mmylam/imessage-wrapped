//
//  imessage_wrappedApp.swift
//  imessage-wrapped
//
//  Created by Tommy Lam on 7/4/23.
//

import SwiftUI
import Contacts

class ContactsPermission: ObservableObject {
    @Published var isGranted = false
    @Published var showSettingsAlert = false
    var settingsURL = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Contacts")
    
    func requestAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            completionHandler(true)
        case .denied, .restricted:
            showSettingsAlert = true
            completionHandler(false)
        case .notDetermined:
            let contactStore = CNContactStore()
            contactStore.requestAccess(for: .contacts) { granted, error in
                if granted {
                    completionHandler(true)
                } else {
                    DispatchQueue.main.async {
                        self.showSettingsAlert = true
                        completionHandler(false)
                    }
                }
            }
        @unknown default:
            completionHandler(false)
        }
    }
}

@main
struct imessage_wrappedApp: App {
    @StateObject private var contactsPermission = ContactsPermission()
    
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
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                Color(NSColor.controlBackgroundColor)
                    .edgesIgnoringSafeArea(.all)
                if !hasFullDiskAccess() {
                    EnableFullDiskAccessView()
                } else {
                    ContactsView()
                        .environmentObject(contactsPermission)
                        .onAppear {
                            contactsPermission.requestAccess { granted in
                                contactsPermission.isGranted = granted
                            }
                        }
                    
                        .alert(isPresented: $contactsPermission.showSettingsAlert) {
                            Alert(
                                title: Text("This app requires access to Contacts to proceed."),
                                message: Text("Go to System Preferences > Security & Privacy > Privacy > Contacts and grant access to your contacts."),
                                primaryButton: .default(Text("Open System Preferences"), action: {
                                    NSWorkspace.shared.open(contactsPermission.settingsURL!)
                                }),
                                secondaryButton: .cancel()
                            )
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }
}
