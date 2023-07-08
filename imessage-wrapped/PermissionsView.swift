//
//  EnablePermsView.swift
//  imessage-wrapped
//
//  Created by Tommy Lam on 7/8/23.
//

import SwiftUI
import Contacts

struct EnableFullDiskAccessView: View {
    let securityPreferencesURL = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")!

    var body: some View {
        VStack(spacing: 16) {
            
            HStack {
                Image(systemName: "folder")
                    .font(.system(size: 30))
                    .foregroundColor(.gray)
                Text("To access iMessage data, you need to grant Full Disk Access permission to this app.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button(action: openSystemPreferences) {
                Text("Open System Preferences")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding()
                    .cornerRadius(10)
            }
        }
        .padding()
        .frame(maxWidth: 700)
    }
    
    func openSystemPreferences() {
            NSWorkspace.shared.open(securityPreferencesURL)
    }
}

struct EnableContactsAccessView: View {
    let securityPreferencesURL = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Contacts")!

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "person.crop.circle.fill.badge.plus")
                    .font(.system(size: 30))
                    .foregroundColor(.gray)
                Text("To access contacts, you need to grant Contacts access permission to this app.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button(action: openSystemPreferences) {
                Text("Open System Preferences")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding()
                    .cornerRadius(10)
            }
        }
        .padding()
        .frame(maxWidth: 700)
    }

    func openSystemPreferences() {
        NSWorkspace.shared.open(securityPreferencesURL)
    }
}

