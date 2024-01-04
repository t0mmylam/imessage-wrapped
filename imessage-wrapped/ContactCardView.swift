import SwiftUI
import Contacts

struct ContactCardView: View {
    var contact: Contact
    
    var body: some View {
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
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Sent: \(contact.sent )")
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

