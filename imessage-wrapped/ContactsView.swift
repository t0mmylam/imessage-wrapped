//
//  ContactsView.swift
//  iMessage Wrapped
//
//  Created by Tommy Lam on 7/4/23.
//

import SwiftUI
import Contacts

struct Contact {
    let contact: CNContact
    var messageCount: String
    var sent: String
    var received: String
    var lateMessageCount: String
}

class ContactsViewModel: ObservableObject {
    @Published var contacts: [Contact] = []
    let db = Database()

    var totalMessageCount: Int {
        contacts.reduce(0) { $0 + (Int($1.messageCount) ?? 0) }
    }

    func loadContacts() {
        DispatchQueue.global().async {
            let store = CNContactStore()
            let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey] as [CNKeyDescriptor]
            let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)

            do {
                try store.enumerateContacts(with: fetchRequest) { (contact, stop) in
                    let phoneNumber = contact.phoneNumbers.first?.value.stringValue ?? ""
                    let messageCount = self.db.getContactMessageCount(number: phoneNumber)
                    let sentCount = self.db.getContactSentMessageCount(number: phoneNumber)
                    let receivedCount = self.db.getContactReceivedMessageCount(number: phoneNumber)
                    let lateMessageCount = self.db.getContactLateMessageCount(number: phoneNumber)

                    if !messageCount.isEmpty {
                        let contact = Contact(contact: contact, messageCount: messageCount, sent: sentCount, received: receivedCount, lateMessageCount: lateMessageCount)
                        DispatchQueue.main.async {
                            self.contacts.append(contact)
                            self.contacts.sort { (contact1, contact2) -> Bool in
                                return Int(contact1.messageCount) ?? 0 > Int(contact2.messageCount) ?? 0
                            }
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
        VStack(spacing: 16) {
            Text("Total Message Count: \(viewModel.totalMessageCount)")
                .font(.title)
                .fontWeight(.bold)

            HStack(spacing: 10) {
                if viewModel.contacts.count > 0 {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Top Contacts")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            ForEach(viewModel.contacts, id: \.contact.identifier) { contact in
                                HStack(spacing: 16) {
                                    if let imageData = contact.contact.imageData, let image = NSImage(data: imageData) {
                                        Image(nsImage: image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
                                    } else {
                                        Image(systemName: "person.crop.circle.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(.blue)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(contact.contact.givenName) \(contact.contact.familyName)")
                                            .font(.headline)
                                        Text("\(contact.messageCount)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding()
                    }
                    .frame(maxHeight: 400) // Set a maximum height for the card content
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.gray.opacity(0.4), radius: 5, x: 0, y: 2)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Sent Texts")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            ForEach(viewModel.contacts, id: \.contact.identifier) { contact in
                                HStack(spacing: 16) {
                                    if let imageData = contact.contact.imageData, let image = NSImage(data: imageData) {
                                        Image(nsImage: image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
                                    } else {
                                        Image(systemName: "person.crop.circle.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(.blue)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(contact.contact.givenName) \(contact.contact.familyName)")
                                            .font(.headline)
                                        Text("\(contact.sent)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding()
                    }
                    .frame(maxHeight: 400) // Set a maximum height for the card content
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.gray.opacity(0.4), radius: 5, x: 0, y: 2)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Received Texts")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            ForEach(viewModel.contacts, id: \.contact.identifier) { contact in
                                HStack(spacing: 16) {
                                    if let imageData = contact.contact.imageData, let image = NSImage(data: imageData) {
                                        Image(nsImage: image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
                                    } else {
                                        Image(systemName: "person.crop.circle.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(.blue)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(contact.contact.givenName) \(contact.contact.familyName)")
                                            .font(.headline)
                                        Text("\(contact.received)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding()
                    }
                    .frame(maxHeight: 400) // Set a maximum height for the card content
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.gray.opacity(0.4), radius: 5, x: 0, y: 2)
                } else {
                    Text("Loading...")
                        .font(.headline)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 16)
        .navigationTitle("iMessage Wrapped")
        .onAppear {
            viewModel.loadContacts()
        }
    }
}

