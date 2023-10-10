//
//  ContactsView.swift
//  iMessage Wrapped
//
//  Created by Tommy Lam on 7/4/23.
//

import SwiftUI
import Contacts
import Charts
import AppKit
import Cocoa

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
    
    var averageMessageCount: String = "0"
    var sortedWordMap: [(String, Int)] = []
    var sortedTextMap: [(String, Int)] = []
    var totalMessageCount: String = "0"
    var sentMessageCount: String = "0"
    var receivedMessageCount: String = "0"
    var monthCounts: [String] = []
    
    func loadData() {
        let wordMap = db.getWordMap()
        sortedWordMap = wordMap.sorted { $0.value > $1.value }
        let textMap = db.getTextMap()
        sortedTextMap = textMap.sorted { $0.value > $1.value }
        sortedTextMap = sortedTextMap.filter { !$0.0.isEmpty && $0.0 != "￼" }
        
        averageMessageCount = db.getAverageMessageCount()
        
        sentMessageCount = db.getSentMessageCount()
        receivedMessageCount = db.getReceivedMessageCount()
        
        if let sentCount = Int(sentMessageCount), let receivedCount = Int(receivedMessageCount) {
            totalMessageCount = String(sentCount + receivedCount)
        } else {
            // Handle the case where either or both values are nil
            totalMessageCount = "N/A"
        }
        
        let monthCounts: [String] = db.getMonthCounts()
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
            
            // Total and Average Message Count Card
            VStack(spacing: 8) {
                Image(systemName: "message.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)
                
                Text("Total Message Count")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("\(viewModel.totalMessageCount)")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Daily Average: \(viewModel.averageMessageCount)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            .cornerRadius(10)
            
            HStack(spacing: 50) {
                if viewModel.contacts.count > 0 {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            // Top Contacts
                            Text("Top Contacts")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            ForEach(viewModel.contacts, id: \.contact.identifier) { contact in
                                // Contact Card
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
                                            .fontWeight(.semibold) // Adjust font weight for the total texts
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("Sent: \(contact.sent)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        Text("Received: \(contact.received)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding()
                    }
                    .frame(maxWidth: 400, maxHeight: 400)
                    .background(Color(NSColor.windowBackgroundColor))
                    .cornerRadius(10)
                } else {
                    Text("Loading...")
                        .font(.headline)
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Word Map")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ForEach(viewModel.sortedWordMap.prefix(10), id: \.0) { wordCount in
                            HStack {
                                Text("\(wordCount.0)")
                                    .font(.headline)
                                Text("(\(wordCount.1) times)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                }
                .frame(maxWidth: 200, maxHeight: 400)
                .background(Color(NSColor.windowBackgroundColor))
                .cornerRadius(10)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Text Map")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ForEach(viewModel.sortedTextMap.prefix(10), id: \.0) { textCount in
                            HStack {
                                Text("\(textCount.0)")
                                    .font(.headline)
                                Text("(\(textCount.1) times)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                }
                .frame(maxWidth: 200, maxHeight: 400)
                .background(Color(NSColor.windowBackgroundColor))
                .cornerRadius(10)
            }
        }
        .padding(.horizontal, 16) // Adjust horizontal padding to make the stack less wide
        .padding(.top, 16)
        .background(Color(NSColor.controlBackgroundColor))
        .navigationTitle("iMessage Wrapped")
        .onAppear {
            viewModel.loadData()
            viewModel.loadContacts()
        }
    }
}
