//
//  AppDelegate.swift
//  CD
//
//  Created by Clay Ellis on 3/16/18.
//  Copyright © 2018 Clay Ellis. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var coreDataStack: CoreDataStack!
    let url = URL(fileURLWithPath: "/Users/clay/Desktop/CD/CD.sqlite")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        resetStore()
        coreDataStack = CoreDataStack(modelName: "CD", url: url)
        coreDataStack.loadStore { error in
            if let error = error {
                fatalError("Failed to load store: \(error)")
            }

            self.run()
        }

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
        return true
    }

    func resetStore() {
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

    func run() {
        let contactStore = ContactStore(coreDataStack: coreDataStack)
        let messageStore = MessageStore(coreDataStack: coreDataStack)
        let conversationStore = ConversationStore(coreDataStack: coreDataStack)

        let contact = Contact(id: "contact.1", name: "Clay Ellis")
        let message = Message(id: "message.1", messageListID: "messageList.1", body: "Hello, Clay.", timestamp: Date())
        let conversation = Conversation(contact: contact, mostRecentMessage: message)

        conversationStore.store(conversation: conversation)

        delay {
            contactStore.store(contact: contact)
        }

        delay {
            messageStore.store(message: message)
        }

        delay {
            let newMessage = Message(id: "message.2", messageListID: message.messageListID, body: "The second message", timestamp: Date())
            messageStore.store(message: newMessage)
        }
    }

    var delayOffset: TimeInterval = 0

    func delay(_ closure: @escaping () -> Void) {
        delayOffset += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + delayOffset) {
            closure()
        }
    }
}
