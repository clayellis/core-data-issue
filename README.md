*In hindsight, I think I was just using Core Data incorrectly. Though, the documentation did have some ambiguous language that led me to believe that it *could* work that way. Lesson learned!*

#  Notes

The issue that I'm seeing is that Core Data fails to insert a new instance of a unique (constrained) object and update a relationship using the new object in the same `save` operation.

It should be reasonable to expect Core Data to apply the correct merge policy and update the relationship in a single operation. But for some unknown reason, it can't (or doesn't).

### The expected behavior is:
1. Insert a new instance of a unique object.
2. Fetch the source object that the new instance is related to (as a destination).
3. Establish the relationship between the new instance (destination) and the fetched object (source).
4. Save the context.

### The expected outcome is:
1. The new instance is stored and updated.
2. The relationship between the new instance and the fetched object is established.

### The actual outcome is:
1. The new instance is stored and updated. (***Expected***)
2. The relationship between the source and destination object is broken. (***Unexpected***)

### The work-around solution is:
1. Fetch the object (if it doesn't exist, insert a new instance) (this is the destination object)
2. Fetch the source object the
3. Update the destination object and the relationship between source and destination
4. Save the context.

# Demonstration Model

In this demonstration there are three models: `Contact`, `Message`, and `Conversation`. Each model has a Core Data variant named `*Data`.

### `Contact`

```swift
struct Contact {
    let id: String
    let name: String
}
```

A `Contact`'s Core Data variant (`ContactData`) is uniquely constrained by its `id`.

### `Message`

```swift
struct Message {
    let id: String
    let messageListID: String
    let body: String
    let timestamp: Date
}
```
A `Message`'s Core Data variant (`MessageData`) is uniquely constrained by its `id`.

### `Conversation`

```swift
struct Conversation {
    let contact: Contact
    let mostRecentMessage: Message

    var messageListID: String {
        return mostRecentMessage.messageListID
    }
}
```

A `Conversation`'s Core Data variant (`ConversationData`) is uniquely constrained by its `messageListID`.

`ConversationData` has a to-one relationship with a `ContactData` and a `MessageData`.
