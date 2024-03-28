# FSContactStore

[![Swift Version][swift-image]][swift-url]
[![License][license-image]][license-url]
![GitHub release (with filter)](https://img.shields.io/github/v/release/LLCFreedom-Space/fs-contact-store)
[![Read the Docs](https://readthedocs.org/projects/docs/badge/?version=latest)](https://llcfreedom-space.github.io/fs-contact-store/)
![example workflow](https://github.com/LLCFreedom-Space/fs-contact-store/actions/workflows/docc.yml/badge.svg?branch=main)
![example workflow](https://github.com/LLCFreedom-Space/fs-contact-store/actions/workflows/lint.yml/badge.svg?branch=main)
![example workflow](https://github.com/LLCFreedom-Space/fs-contact-store/actions/workflows/test.yml/badge.svg?branch=main)
[![codecov](https://codecov.io/github/LLCFreedom-Space/fs-contact-store/graph/badge.svg?token=2EUIA4OGS9)](https://codecov.io/github/LLCFreedom-Space/fs-contact-store)

`FSContactStore` is a Swift package that provides a convenient and easy-to-use interface for interacting with Apple's `Contacts` framework on iOS and macOS.

## Features

* Simplified authorization handling for requesting access to contacts.
* Flexible fetching options for retrieving contacts with filtering, sorting, and specifying properties to retrieve.
* Support for unified contacts, which combine information from multiple sources.
* Shared instance for quick access to common functionalities.
* Customizable save requests to allow tailoring logic for adding, updating, and deleting contacts.

## Installation

Add the package to your Package.swift file:

```swift
dependencies: [
.package(url: "https://github.com/LLCFreedom-Space/fs-contact-store", from: "1.0.0")
]
```

Import the package in your Swift files:

```swift
import ContactStore
```

## Usage

1. Import the library:

```swift
import ContactStore
```

2. Accessing the Shared Instance:

```swift
let store = ContactStore.shared
```

3. Checking Authorization Status:

```swift
let status = store.authorizationStatus()

if status != .authorized {
do {
try await store.requestAccess()
} catch {
// Handle access request error
}
}
```

4. Fetching Contacts:

* Fetch all contacts with required keys:

```swift
do {
let contacts = try await store.fetch()
// Access contact properties here
} catch {
// Handle fetch error
}
```

* Fetch contacts by name:

```swift 
let name = "John Doe"
do {
let contacts = try store.fetch(by: name)
// ...
} catch {
// Handle fetch error
}
```

5. Managing Contacts:
* Adding a new contact:

```swift
let newContact = CNMutableContact()
newContact.givenName = "Jane"
newContact.familyName = "Smith"

do {
try store.add(newContact)
} catch {
// Handle add error
}
```

* Updating a contact:
```swift
// ... modify contact properties
try store.update(contact)
```

* Deleting a contact:

```swift
// ... select contact
try store.delete(contact)
```

6. Customizing Save Requests (Optional):

By default, `ContactStore` uses a standard `CNSaveRequest` instance. 
You can modify the static closure `ContactStore.makeCNSaveRequest` to inject custom logic or provide different request implementations.
**Important:** To modify the `ContactStore.makeCNSaveRequest` closure, you must use the `use(_:)` method.

```swift
ContactStore.use { request in
  // Make changes to the request
  // ...
  return request
}
```

This code updates the `ContactStore.makeCNSaveRequest` closure to accept a `CNSaveRequest` instance as an argument, 
make any necessary changes to it, and then return the updated request.

7. Customizing Authorization Status (Optional):

By default, `ContactStore` uses the actual authorization status from the system's `CNContactStore`. 
However, you can override this behavior with a custom closure to inject specific authorization statuses for testing or other purposes.

Here's how to customize the authorization status:

**Use the `use(_:)` method:**

- Call the `use(_:)` method on `ContactStore` to provide a custom closure for creating `CNAuthorizationStatus` instances.
- The closure accepts no arguments and returns a `CNAuthorizationStatus` value.
 
 **Implement the closure logic:**

- Within the closure, specify the desired authorization status to be returned. 
  You can return a fixed value or implement more complex logic based on your needs.

```swift
ContactStore.use {
    return .denied // Simulate denied authorization status
}

let currentStatus = ContactStore.authorizationStatus()
// currentStatus will now be .denied
```

## Contributions

We welcome contributions to this project! Please feel free to open issues or pull requests to help improve the package.

## Links

LLC Freedom Space – [@LLCFreedomSpace](https://twitter.com/llcfreedomspace) – [support@freedomspace.company](mailto:support@freedomspace.company)

Distributed under the GNU AFFERO GENERAL PUBLIC LICENSE Version 3. See [LICENSE.md][license-url] for more information.

 [GitHub](https://github.com/LLCFreedom-Space)

[swift-image]:https://img.shields.io/badge/swift-5.8-orange.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-GPLv3-blue.svg
[license-url]: LICENSE
