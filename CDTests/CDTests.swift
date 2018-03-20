//
//  CDTests.swift
//  CDTests
//
//  Created by Clay Ellis on 3/16/18.
//  Copyright © 2018 Clay Ellis. All rights reserved.
//

import XCTest
import CoreData
@testable import CD

class CDTests: XCTestCase {

    let testDirectoryURL = URL(fileURLWithPath: "/tmp/cd-test/")
    lazy var testStoreURL = testDirectoryURL.appendingPathComponent("Test.sqlite")
    var coreDataStack: CoreDataStackProtocol!
    var contactStore: ContactStore!
    var messageStore: MessageStore!
    var conversationStore: ConversationStore!

    override func setUp() {
        super.setUp()
        createStoreDirectory()
        let type = NSSQLiteStoreType
        do {
            coreDataStack = try CoreDataStack(modelName: "CD", url: testStoreURL, type: type)
        } catch {
            XCTFail("Failed to initialize CoreDataStack: \(error.humanReadableString)")
            tearDown()
            return
        }
        contactStore = ContactStore(coreDataStack: coreDataStack)
        messageStore = MessageStore(coreDataStack: coreDataStack)
        conversationStore = ConversationStore(coreDataStack: coreDataStack)
    }
    
    override func tearDown() {
        coreDataStack.close()
        coreDataStack = nil
        contactStore = nil
        messageStore = nil
        conversationStore = nil
        deleteStoreDirectory()
        super.tearDown()
    }

    // MARK: - Store Managements

    private func createStoreDirectory() {
        deleteStoreDirectory()
        try? FileManager.default.createDirectory(at: testDirectoryURL, withIntermediateDirectories: true, attributes: nil)
    }

    private func deleteStoreDirectory() {
        try? FileManager.default.removeItem(at: testDirectoryURL)
    }

    // MARK: - Fetches

    private func fetch(_ contact: Contact) throws -> ContactData? {
        return try coreDataStack.viewContext.fetch(contact)
    }

    private func fetch(_ message: Message) throws -> MessageData? {
        return try coreDataStack.viewContext.fetch(message)
    }

    private func fetch(_ conversation: Conversation) throws -> ConversationData? {
        return try coreDataStack.viewContext.fetch(conversation)
    }

    // MARK: - Counts

    private func contactsCount() throws -> Int {
        let request: NSFetchRequest<ContactData> = ContactData.fetchRequest()
        return try coreDataStack.viewContext.count(for: request)
    }

    private func messagesCount() throws -> Int {
        let request: NSFetchRequest<MessageData> = MessageData.fetchRequest()
        return try coreDataStack.viewContext.count(for: request)
    }

    private func conversationsCount() throws -> Int {
        let request: NSFetchRequest<ConversationData> = ConversationData.fetchRequest()
        return try coreDataStack.viewContext.count(for: request)
    }

    // MARK: Perform Test

    private func performTest(_ test: @escaping () throws -> Void) {
        let expectation = XCTestExpectation(description: "asynchronous test ran")
        coreDataStack.loadStore { error in
            if let error = error {
                XCTFail("Error loading store: \(error.humanReadableString)")
                return
            }

            do {
                try test()
                expectation.fulfill()
            } catch {
                XCTFail("Test threw error: \(error.humanReadableString)")
            }
        }
        wait(for: [expectation], timeout: 5)
    }

    // MARK: - Tests

    func testStackStartsEmpty() {
        performTest {
            let objectCount = self.coreDataStack.viewContext.registeredObjects.count
            XCTAssertEqual(objectCount, 0)
        }
    }

    func testStoreContact() {
        performTest {
            let contact = Contact(id: "contact.1", name: "Name")
            self.contactStore.store(contact)
            let fetched = try self.fetch(contact)
            XCTAssertNotNil(fetched)
            XCTAssertEqual(fetched?.id, contact.id)
            XCTAssertEqual(fetched?.name, contact.name)
        }
    }

    func testStoreMessage() {
        performTest {
            let message = Message(id: "message.1", messageListID: "list.1", body: "Body", timestamp: Date())
            self.messageStore.store(message)
            let fetched = try self.fetch(message)
            XCTAssertNotNil(fetched)
            XCTAssertEqual(fetched?.id, message.id)
            XCTAssertEqual(fetched?.messageListID, message.messageListID)
            XCTAssertEqual(fetched?.body, message.body)
            XCTAssertEqual(fetched?.timestamp as Date?, message.timestamp)
        }
    }

    func testStoreConversation() {
        performTest {
            let contact = Contact(id: "contact.1", name: "Name")
            let message = Message(id: "message.1", messageListID: "list.1", body: "Body", timestamp: Date())
            let conversation = Conversation(contact: contact, mostRecentMessage: message)
            self.conversationStore.store(conversation)
            let fetched = try self.fetch(conversation)
            XCTAssertNotNil(fetched)
            XCTAssertEqual(fetched?.messageListID, conversation.messageListID)
            XCTAssertEqual(fetched?.contact?.id, conversation.contact.id)
            XCTAssertEqual(fetched?.mostRecentMessage?.id, conversation.mostRecentMessage.id)
            XCTAssertEqual(try self.fetch(message)?.conversation?.messageListID, conversation.messageListID)
            XCTAssertEqual(try self.fetch(contact)?.conversation?.messageListID, conversation.messageListID)
        }
    }

    func testUniqueContacts() throws {
        performTest {
            let id = "contact.1"
            let contact = Contact(id: id, name: "Name")
            let updatedContact = Contact(id: id, name: "Updated Name")
            self.contactStore.store(contact)
            XCTAssertEqual(try self.contactsCount(), 1)
            XCTAssertEqual(try self.fetch(contact)?.name, contact.name)
            self.contactStore.store(updatedContact)
            XCTAssertEqual(try self.contactsCount(), 1)
            XCTAssertEqual(try self.fetch(updatedContact)?.name, updatedContact.name)
        }
    }

    func testUniqueMessages() {
        performTest {
            let id = "messsage.1"
            let message = Message(id: id, messageListID: "list.1", body: "Hello", timestamp: Date())
            let updatedMessage = Message(id: id, messageListID: message.messageListID, body: "Hello, World.", timestamp: message.timestamp)
            self.messageStore.store(message)
            XCTAssertEqual(try self.messagesCount(), 1)
            XCTAssertEqual(try self.fetch(message)?.body, message.body)
            self.messageStore.store(updatedMessage)
            XCTAssertEqual(try self.messagesCount(), 1)
            XCTAssertEqual(try self.fetch(updatedMessage)?.body, updatedMessage.body)
        }
    }

    func testUniqueConversations() {
        performTest {
            let listID = "list.1"
            let contact = Contact(id: "contact.1", name: "Name")
            let message = Message(id: "message.1", messageListID: listID, body: "Body", timestamp: Date())
            let conversation = Conversation(contact: contact, mostRecentMessage: message)
            self.conversationStore.store(conversation)
            XCTAssertEqual(try self.conversationsCount(), 1)
            XCTAssertEqual(try self.fetch(conversation)?.mostRecentMessage?.id, message.id)
            let newMessage = Message(id: "message.2", messageListID: listID, body: "New", timestamp: Date())
            let updatedConversation = Conversation(contact: contact, mostRecentMessage: newMessage)
            self.conversationStore.store(updatedConversation)
            XCTAssertEqual(try self.conversationsCount(), 1)
            XCTAssertEqual(try self.fetch(conversation)?.mostRecentMessage?.id, newMessage.id)
        }
    }

    // Store: Conversation, Contact, Message (relationships should be established/stable after all three)
    func testStoreConversationContactMessage() {
        performTest {
            let message = Message(id: "message.1", messageListID: "list.1", body: "One", timestamp: Date())
            let contact = Contact(id: "contact.1", name: "Bob")
            let conversation = Conversation(contact: contact, mostRecentMessage: message)

            // Store the conversation
            self.conversationStore.store(conversation)

            // The contact, message, and conversation should be stored (and there should be one of each)
            XCTAssertEqual(try self.contactsCount(), 1)
            XCTAssertEqual(try self.messagesCount(), 1)
            XCTAssertEqual(try self.conversationsCount(), 1)

            // And the conversation should point to the contact and the message
            XCTAssertEqual(try self.fetch(conversation)?.contact?.id, contact.id)
            XCTAssertEqual(try self.fetch(conversation)?.mostRecentMessage?.id, message.id)

            // Store the contact on its own
            self.contactStore.store(contact)

            // There should still be only one contact
            XCTAssertEqual(try self.contactsCount(), 1)

            // And the conversation should still point to the contact
            XCTAssertEqual(try self.fetch(conversation)?.contact?.id, contact.id)

            // Store the message on its own
            self.messageStore.store(message)

            // There should still be only one message
            XCTAssertEqual(try self.messagesCount(), 1)

            // And the conversation should still point to the message
            XCTAssertEqual(try self.fetch(conversation)?.mostRecentMessage?.id, message.id)
        }
    }

    // Store: Conversation, New Message (conversation should point to new message)
    func testStoreConversationNewMessage() {
        performTest {
            let message = Message(id: "message.1", messageListID: "list.1", body: "One", timestamp: Date())
            let contact = Contact(id: "contact.1", name: "Bob")
            let conversation = Conversation(contact: contact, mostRecentMessage: message)

            // Store the conversation
            self.conversationStore.store(conversation)

            // The message, and conversation should be stored (and there should be one of each)
            XCTAssertEqual(try self.messagesCount(), 1)
            XCTAssertEqual(try self.conversationsCount(), 1)

            // The conversation should point to the message, and the inverse
            XCTAssertEqual(try self.fetch(conversation)?.mostRecentMessage?.id, message.id)
            XCTAssertEqual(try self.fetch(message)?.conversation?.messageListID, conversation.messageListID)

            // Create a new message and store it
            let newMessage = Message(id: "message.2", messageListID: message.messageListID, body: "Two", timestamp: Date())
            self.messageStore.store(newMessage)

            // There should be two messages in the store
            XCTAssertEqual(try self.messagesCount(), 2)

            // The conversation should point to the new message, and the inverse
            XCTAssertEqual(try self.fetch(conversation)?.mostRecentMessage?.id, newMessage.id)
            XCTAssertEqual(try self.fetch(newMessage)?.conversation?.messageListID, conversation.messageListID)

            // The old message should not point to a conversation
            XCTAssertNil(try self.fetch(message)?.conversation)
        }
    }

    // Store: Conversation, Old Message (conversation should still point to original message)
    func testStoreConversationOldMessage() {
        performTest {
            let listID = "list.1"
            let olderMessage = Message(id: "message.0", messageListID: listID, body: "Old", timestamp: Date())
            let newerMessage = Message(id: "message.1", messageListID: listID, body: "New", timestamp: Date(timeInterval: 1, since: olderMessage.timestamp))
            let contact = Contact(id: "contact.1", name: "Bob")
            let conversation = Conversation(contact: contact, mostRecentMessage: newerMessage)

            // Store the conversation
            self.conversationStore.store(conversation)

            // The message, and conversation should be stored (and there should be one of each)
            XCTAssertEqual(try self.messagesCount(), 1)
            XCTAssertEqual(try self.conversationsCount(), 1)

            // The conversation should point to the newer message
            XCTAssertEqual(try self.fetch(conversation)?.mostRecentMessage?.id, newerMessage.id)

            // Store the older message
            self.messageStore.store(olderMessage)

            // There should be two messages in the store
            XCTAssertEqual(try self.messagesCount(), 2)

            // The conversation should still point to the newer message
            XCTAssertEqual(try self.fetch(conversation)?.mostRecentMessage?.id, newerMessage.id)
        }
    }

    // Store: Conversation, New Message in different list (conversation should still point to the original message)
    func testStoreConversationNewMessageDifferentList() {
        performTest {
            let message = Message(id: "message.0", messageListID: "list.1", body: "Body", timestamp: Date())
            let messageInDifferentList = Message(id: "message.1", messageListID: "list.2", body: "Different", timestamp: Date(timeInterval: 1, since: message.timestamp))
            let contact = Contact(id: "contact.1", name: "Bob")
            let conversation = Conversation(contact: contact, mostRecentMessage: message)

            // Store the conversation
            self.conversationStore.store(conversation)

            // The message, and conversation should be stored (and there should be one of each)
            XCTAssertEqual(try self.messagesCount(), 1)
            XCTAssertEqual(try self.conversationsCount(), 1)

            // The conversation should point to the newer message
            XCTAssertEqual(try self.fetch(conversation)?.mostRecentMessage?.id, message.id)

            // Store the newer message (that's in a different list)
            self.messageStore.store(messageInDifferentList)

            // There should be two messages in the store
            XCTAssertEqual(try self.messagesCount(), 2)

            // The conversation should still point to the original message
            XCTAssertEqual(try self.fetch(conversation)?.mostRecentMessage?.id, message.id)
        }
    }

    // Store: Conversation, Conversation (i.e. refresh the conversation. Relationships should be stable)
    func testRefreshConversation() {
        performTest {
            let message = Message(id: "message.1", messageListID: "list.1", body: "One", timestamp: Date())
            let contact = Contact(id: "contact.1", name: "Bob")
            let conversation = Conversation(contact: contact, mostRecentMessage: message)

            // Store the conversation
            self.conversationStore.store(conversation)

            // The contact, message, and conversation should be stored (and there should be one of each)
            XCTAssertEqual(try self.contactsCount(), 1)
            XCTAssertEqual(try self.messagesCount(), 1)
            XCTAssertEqual(try self.conversationsCount(), 1)

            // The conversation should point to the message, and the inverse
            XCTAssertEqual(try self.fetch(conversation)?.mostRecentMessage?.id, message.id)
            XCTAssertEqual(try self.fetch(message)?.conversation?.messageListID, conversation.messageListID)

            // Store the conversation again (refresh)
            self.conversationStore.store(conversation)

            // The same tests as before should hold
            XCTAssertEqual(try self.contactsCount(), 1)
            XCTAssertEqual(try self.messagesCount(), 1)
            XCTAssertEqual(try self.conversationsCount(), 1)
            XCTAssertEqual(try self.fetch(conversation)?.mostRecentMessage?.id, message.id)
            XCTAssertEqual(try self.fetch(message)?.conversation?.messageListID, conversation.messageListID)
        }
    }

    // Store: Conversation, Updated Contact (conversation should have contact updates)
    func testStoreConversationUpdateContact() {
        performTest {
            let message = Message(id: "message.1", messageListID: "list.1", body: "One", timestamp: Date())
            let contact = Contact(id: "contact.1", name: "Bob")
            let conversation = Conversation(contact: contact, mostRecentMessage: message)

            // Store the conversation
            self.conversationStore.store(conversation)

            // The contact and conversation should be stored (and there should be one of each)
            XCTAssertEqual(try self.contactsCount(), 1)
            XCTAssertEqual(try self.conversationsCount(), 1)

            // The conversation should point to the contact, and the inverse
            XCTAssertEqual(try self.fetch(conversation)?.contact?.id, contact.id)
            XCTAssertEqual(try self.fetch(contact)?.conversation?.messageListID, conversation.messageListID)

            // The conversation's contact should have the first contact's name
            XCTAssertEqual(try self.fetch(conversation)?.contact?.name, contact.name)

            // Update the contact and store it
            let updatedContact = Contact(id: contact.id, name: "Updated")
            self.contactStore.store(updatedContact)

            // There should still only be one contact stored
            XCTAssertEqual(try self.contactsCount(), 1)

            // The conversation should point to the updated contact, and the inverse
            XCTAssertEqual(try self.fetch(conversation)?.contact?.id, updatedContact.id)
            XCTAssertEqual(try self.fetch(updatedContact)?.conversation?.messageListID, conversation.messageListID)

            // The conversation's contact should have the updated contact's name
            XCTAssertEqual(try self.fetch(conversation)?.contact?.name, updatedContact.name)
        }
    }

}
