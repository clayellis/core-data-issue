//
//  Runner.swift
//  CD
//
//  Created by Clay Ellis on 3/19/18.
//  Copyright © 2018 Clay Ellis. All rights reserved.
//

import Foundation
import CoreData

class Runner {
    var coreDataStack: CoreDataStackProtocol!
    let url = URL(fileURLWithPath: "/Users/clay/Desktop/CD/CD.sqlite")

    lazy var contactStore = ContactStore(coreDataStack: coreDataStack)
    lazy var messageStore = MessageStore(coreDataStack: coreDataStack)
    lazy var conversationStore = ConversationStore(coreDataStack: coreDataStack)

    init() {
        resetStore()
        let type = NSSQLiteStoreType
        coreDataStack = CoreDataStack(modelName: "CD", url: url, type: type)
        coreDataStack.loadStore { error in
            if let error = error {
                fatalError("Failed to load store: \(error)")
            }

            self.run()
        }
    }

    // MARK: - Private

    private func resetStore() {
        let directoryURL = url.deletingLastPathComponent()
        do {
            try FileManager.default.removeItem(at: directoryURL)
        } catch {
            print("Failed to delete store directory \(directoryURL): \(error)")
        }

        do {
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: false, attributes: nil)
        } catch {
            print("Failed to create store directory \(directoryURL): \(error)")
        }
    }

    private var delayOffset: TimeInterval = 0

    private func delay(_ closure: @escaping () -> Void) {
        closure()
        delayOffset += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + delayOffset) {
            closure()
        }
    }

    // MARK: - Public

    func run() {
        let contact = Contact(id: "contact.1", name: "Clay Ellis")
        let message = Message(id: "message.1", messageListID: "messageList.1", body: "Hello, Clay.", timestamp: Date(timeIntervalSinceNow: 0))
        let conversation = Conversation(contact: contact, mostRecentMessage: message)
        let updatedContact = Contact(id: contact.id, name: "Clayton Ellis")
        let newMessage = Message(id: "message.2", messageListID: message.messageListID, body: "Hello, Clayton.", timestamp: Date(timeIntervalSinceNow: 5))
        let updatedConversation = Conversation(contact: updatedContact, mostRecentMessage: newMessage)
        let newerMessage = Message(id: "message.3", messageListID: message.messageListID, body: "I have a question.", timestamp: Date(timeIntervalSinceNow: 10))

        conversationStore.store(conversation)

        delay {
            self.contactStore.store(contact)
        }

        delay {
            self.contactStore.store(updatedContact)
        }

        delay {
            self.contactStore.store(updatedContact)
        }

        delay {
            self.messageStore.store(message)
        }

        delay {
            self.conversationStore.store(conversation)
        }

        delay {
            self.messageStore.store(newMessage)
        }

        delay {
            self.contactStore.store(updatedContact)
        }

        delay {
            self.conversationStore.store(updatedConversation)
        }

        delay {
            self.messageStore.store(newerMessage)
        }
    }
}
