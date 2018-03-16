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
1. The new instance is stored and updated. (Expected)
2. The relationship between the source and destination object is broken. (Unexpected)

### The current workaround is:
1. Insert a new instance of a unique object.
2. Save the context. (Applies merge policy).
3. Fetch the newly inserted object.
4. Fetch the source object that new object is related to (as a destination).
5. Establish the relationship between the new fetched object (destination) and the fetched object (source).
6. Save the context.

**The workaround produces the expected outcome.** But it is not ideal because of the intermediate save and fetch steps.
