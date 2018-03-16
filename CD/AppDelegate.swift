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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        coreDataStack = CoreDataStack(modelName: "CD")
        run()

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
        return true
    }

    func run() {
        let contactStore = ContactStore(coreDataStack: coreDataStack)
        let messageStore = MessageStore(coreDataStack: coreDataStack)
        let conversationStore = ConversationStore(coreDataStack: coreDataStack)

        let contact = Contact(id: "contact.1", name: "Clay Ellis")
        let message = Message(id: "message.1", messageListID: "messageList.1", body: "Hello, Clay.")
        let conversation = Conversation(contact: contact, mostRecentMessage: message)

        conversationStore.store(conversation: conversation)
        contactStore.store(contact: contact)
        messageStore.store(message: message)
    }
}
