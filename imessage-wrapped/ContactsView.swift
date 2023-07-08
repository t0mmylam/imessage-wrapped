//
//  ContactsView.swift
//  iMessage Wrapped
//
//  Created by Tommy Lam on 7/4/23.
//

import SwiftUI
import Contacts

struct ContactWithMessageCount {
    let contact: CNContact
    var messageCount: String
}

class ContactsViewModel: ObservableObject {
    @Published var contacts: [ContactWithMessageCount] = []
    let db = Database()

    func loadContacts() {
        DispatchQueue.global().async {
            let store = CNContactStore()
            let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
            let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)

            do {
                try store.enumerateContacts(with: fetchRequest) { (contact, stop) in
                    let phoneNumber = contact.phoneNumbers.first?.value.stringValue ?? ""
                    let messageCount = self.db.getMessageCount(number: phoneNumber)

                    if !messageCount.isEmpty {
                        let contactWithMessageCount = ContactWithMessageCount(contact: contact, messageCount: messageCount)
                        DispatchQueue.main.async {
                            self.contacts.append(contactWithMessageCount)
                        }
                    }
                }
            } catch {
                print("Failed to fetch contacts: \(error.localizedDescription)")
            }
        }
    }
}

struct ContactsView: View {
    @StateObject private var viewModel = ContactsViewModel()

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 200), spacing: 16)], spacing: 16) {
                ForEach(viewModel.contacts, id: \.contact.identifier) { contact in
                    VStack(spacing: 8) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .foregroundColor(.blue)
                        Text("\(contact.contact.givenName) \(contact.contact.familyName)")
                            .font(.headline)
                        Text("\(contact.messageCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.gray.opacity(0.4), radius: 5, x: 0, y: 2)
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)
        }
        .navigationTitle("Contacts")
        .onAppear {
            viewModel.loadContacts()
        }
    }
}
