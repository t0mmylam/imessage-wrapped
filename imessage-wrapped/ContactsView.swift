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

struct Contact {
    let contact: CNContact
    var messageCount: String
    var sent: String
    var received: String
    var lateMessageCount: String
}

class ContactsViewModel: ObservableObject {
    func standardizePhoneNumber(_ number: String) -> String {
        // Remove all characters except digits and the leading plus.
        let digitsCharacterSet = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: "+"))
        let filteredCharacters = number.unicodeScalars.filter { digitsCharacterSet.contains($0) }
        let filteredNumber = String(String.UnicodeScalarView(filteredCharacters))
        
        // Check if the number already contains the plus sign
        if filteredNumber.hasPrefix("+") {
            // Number is already in international format
            return filteredNumber
        } else {
            // Assume the number is missing the "+" and prepend it
            return "+\(filteredNumber)"
        }
    }
    
    @Published var searchText = ""
    var filteredContacts: [Contact] {
        if searchText.isEmpty {
            return contacts
        } else {
            return contacts.filter { contact in
                contact.contact.givenName.lowercased().contains(searchText.lowercased()) ||
                contact.contact.familyName.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    @Published var contacts: [Contact] = []
    let db = Database()
    
    var averageMessageCount: String = "0"
    var averageSentCount: String = "0"
    var averageReceivedCount: String = "0"
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
        
        averageSentCount = db.getAverageSentCount()
        averageReceivedCount = db.getAverageReceivedCount()
        if let doubleSC = Double(averageSentCount), let doubleRC = Double(averageReceivedCount) {
            averageMessageCount = String(format: "%.3f", doubleSC + doubleRC)
        } else {
            averageMessageCount = "N/A"
        }
        
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
            let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey, CNContactEmailAddressesKey] as [CNKeyDescriptor]
            let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
            
            do {
                try store.enumerateContacts(with: fetchRequest) { (contact, stop) in
                    var phoneNumber = contact.phoneNumbers.first?.value.stringValue ?? ""
                    phoneNumber = self.standardizePhoneNumber(phoneNumber)
                    let email = contact.emailAddresses.first?.value ?? ""
                    if phoneNumber == "+" {
                        phoneNumber = email as String
                    }
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

struct MessageStatsCard: View {
    var icon: String
    var title: String
    var count: String
    var average: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.blue)
            
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("\(count)")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Daily Average: \(average)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(10)
    }
}

struct ContactsView: View {
    @StateObject private var viewModel = ContactsViewModel()
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search Contacts", text: $viewModel.searchText) // Bind TextField to searchText
                        .foregroundColor(.primary)
                        .focused($isFocused) // Bind the focus state
                }
                .padding(8)
                .background(Color(NSColor.textBackgroundColor)) // Use UIColor for iOS
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isFocused ? Color.blue : Color.gray, lineWidth: isFocused ? 2 : 0.5)
                )
                .frame(maxWidth: 400)
                
                if viewModel.contacts.count > 0 {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(viewModel.filteredContacts, id: \.contact.identifier) { contact in
                                ContactCardView(contact: contact)
                            }
                        }
                        .padding()
                    }
                    .frame(maxWidth: 400)
                    .cornerRadius(10)
                } else {
                    Text("Loading...")
                        .font(.headline)
                }
            }
            .background(Color(NSColor.windowBackgroundColor))
            
            VStack() {
                HStack(spacing: 0) {
                    MessageStatsCard(
                        icon: "message.fill",
                        title: "Total",
                        count: viewModel.totalMessageCount,
                        average: viewModel.averageMessageCount
                    )
                    
                    MessageStatsCard(
                        icon: "arrow.right.circle.fill",
                        title: "Sent",
                        count: viewModel.sentMessageCount,
                        average: viewModel.averageSentCount
                    )
                    
                    MessageStatsCard(
                        icon: "envelope.fill",
                        title: "Received",
                        count: viewModel.receivedMessageCount,
                        average: viewModel.averageReceivedCount
                    )
                }
                
                HStack(spacing: 10) {
                    ZStack(alignment: .top) {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                Spacer()
                                    .frame(height: 20)
                                
                                ForEach(Array(viewModel.sortedWordMap.prefix(50).enumerated()), id: \.1.0) { index, wordCount in
                                    HStack {
                                        Text("\(index + 1). \(wordCount.0)")
                                            .font(.headline)
                                        Text("(\(wordCount.1) times)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding()
                        }
                        .frame(maxWidth: 200, maxHeight: 350)
                        .background(Color(NSColor.windowBackgroundColor))
                        .cornerRadius(10)
                        
                        // Persistent title
                        Text("Most Texted Words")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                            .padding(.top, 20)
                            .background(Color(NSColor.windowBackgroundColor))
                            .cornerRadius(10)
                    }
                    
                    ZStack(alignment: .top) {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                Spacer()
                                    .frame(height: 20)
                                
                                ForEach(Array(viewModel.sortedTextMap.prefix(50).enumerated()), id: \.1.0) { index, textCount in
                                    HStack {
                                        Text("\(index + 1). \(textCount.0)")
                                            .font(.headline)
                                        Text("(\(textCount.1) times)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding()
                        }
                        .frame(maxWidth: 200, maxHeight: 350)
                        .background(Color(NSColor.windowBackgroundColor))
                        .cornerRadius(10)
                        
                        Text("Most Sent Texts")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                            .padding(.top, 20)
                            .background(Color(NSColor.windowBackgroundColor))
                            .cornerRadius(10)
                    }
                }
            }
            .navigationTitle("iMessage Wrapped")
            .border(.blue)
            .padding(0)
            .onAppear {
                viewModel.loadData()
                viewModel.loadContacts()
            }
        }
        .frame(maxWidth: .infinity)
    }
}
