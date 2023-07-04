//
//  ContactsView.swift
//  iMessage Wrapped
//
//  Created by Tommy Lam on 7/4/23.
//

import SwiftUI
import Contacts

struct ContactsView: View {
    @State private var contacts: [CNContact] = []

    var body: some View {
        List(contacts, id: \.identifier) { contact in
            VStack(alignment: .leading) {
                Text("\(contact.givenName) \(contact.familyName)")
                ForEach(contact.phoneNumbers, id: \.label) { phoneNumber in
                    Text(phoneNumber.value.stringValue)
                }
            }
        }
        .onAppear {
            requestContactsAccess()
        }
    }

    func requestContactsAccess() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, error in
            if granted {
                loadContacts()
            } else if let error = error {
                print("Access denied: \(error.localizedDescription)")
            }
        }
    }

    func loadContacts() {
        let store = CNContactStore()
        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)

        do {
            try store.enumerateContacts(with: fetchRequest) { (contact, stop) in
                self.contacts.append(contact)
            }
        } catch {
            print("Failed to fetch contacts: \(error.localizedDescription)")
        }
    }
}
