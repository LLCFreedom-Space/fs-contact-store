// FS Contact Store
// Copyright (C) 2024  FREEDOM SPACE, LLC

//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Affero General Public License as published
//  by the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Affero General Public License for more details.
//
//  You should have received a copy of the GNU Affero General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.

//
//  ContactStore.swift
//
//
//  Created by Mykhailo Bondarenko on 23.03.2024.
//

@_exported import Contacts

/// A class providing a convenient interface for interacting with the Contacts framework.
final class ContactStore: ContactStoreProtocol {
    /// A shared instance of `ContactStore` for convenience.
    public static let shared = ContactStore()
    
    /// The underlying `CNContactStore` instance used for interactions.
    private let store: CNContactStore
    
    /// A closure for creating `CNSaveRequest` instances, allowing for custom implementations.
    static var makeCNSaveRequest: () -> CNSaveRequest = {
        CNSaveRequest()
    }
    
    /// Initializes a `ContactStore` with the specified `CNContactStore` instance.
    ///
    /// - Parameter store: The `CNContactStore` instance to use.
    public init(store: CNContactStore = CNContactStore()) {
        self.store = store
    }
    
    // MARK: - ContactStoreProtocol implementation
    
    /// Retrieves the current authorization status for accessing contacts.
    ///
    /// - Returns: The current authorization status (e.g., .authorized, .denied).
    public func authorizationStatus() -> CNAuthorizationStatus {
        return CNContactStore.authorizationStatus(for: .contacts)
    }
    
    /// Requests authorization to access contacts asynchronously.
    ///
    /// - Throws: An error if the request fails.
    /// - Returns: `true` if authorization was granted, `false` otherwise.
    public func requestAccess() async throws -> Bool {
        return try await store.requestAccess(for: .contacts)
    }
    
    /// Fetches contacts from the store based on specified parameters.
    ///
    /// - Parameters:
    ///   - keysToFetch: The keys (properties) to retrieve for each contact (defaults to required keys).
    ///   - order: The order in which to sort the results (defaults to none).
    ///   - unifyResults: Whether to unify contact records from multiple sources (defaults to true).
    /// - Throws: An error if the fetch fails.
    /// - Returns: An array of fetched contacts.
    public func fetch(
        keysToFetch keys: [CNKeyDescriptor] = [CNContactVCardSerialization.descriptorForRequiredKeys()],
        order: CNContactSortOrder = .none,
        unifyResults: Bool = true
    ) async throws -> [CNContact] {
        return try await withCheckedThrowingContinuation { continuation in
            var contacts: [CNContact] = []
            let fetchRequest = CNContactFetchRequest(keysToFetch: keys)
            fetchRequest.sortOrder = order
            fetchRequest.unifyResults = unifyResults
            do {
                try autoreleasepool {
                    // TODO: - Need implement handling of pointer in closure
                    try store.enumerateContacts(with: fetchRequest) { contact, _ in
                        contacts.append(contact)
                    }
                }
                continuation.resume(returning: contacts)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    /// Fetches contacts from the store based on a predicate for filtering.
    ///
    /// - Parameters:
    ///   - predicate: The predicate to filter contacts.
    ///   - keysToFetch: The keys (properties) to retrieve for each contact (defaults to required keys).
    /// - Throws: An error if the fetch fails.
    /// - Returns: An array of fetched contacts matching the predicate.
    public func fetch(
        by predicate: NSPredicate,
        keysToFetch keys: [CNKeyDescriptor] = [CNContactVCardSerialization.descriptorForRequiredKeys()]
    ) throws -> [CNContact] {
        return try unifiedContacts(matching: predicate, keysToFetch: keys)
    }
    
    /// Fetches contacts from the store by name.
    ///
    /// - Parameters:
    ///   - name: The name to search for.
    ///   - keysToFetch: The keys (properties) to retrieve for each contact (defaults to required keys).
    /// - Throws: An error if the fetch fails.
    /// - Returns: An array of fetched contacts matching the name.
    public func fetch(
        by name: String,
        keysToFetch keys: [CNKeyDescriptor] = [CNContactVCardSerialization.descriptorForRequiredKeys()]
    ) throws -> [CNContact] {
        return try fetch(by: CNContact.predicateForContacts(matchingName: name), keysToFetch: keys)
    }
    
    /// Fetches a unified contact with the specified identifier.
    ///
    /// - Parameters:
    ///   - identifier: The unique identifier of the contact to fetch.
    ///   - keysToFetch: The keys (properties) to retrieve for each contact (defaults to required keys).
    /// - Throws: An error if the fetch fails.
    /// - Returns: The fetched unified contact with the given identifier.
    public func unifiedContact(
        withIdentifier identifier: String,
        keysToFetch keys: [CNKeyDescriptor] = [CNContactVCardSerialization.descriptorForRequiredKeys()]
    ) throws -> CNContact {
        return try store.unifiedContact(withIdentifier: identifier, keysToFetch: keys)
    }
    
    /// Fetches unified contacts matching a predicate.
    ///
    /// - Parameters:
    ///   - predicate: The predicate to filter contacts.
    ///   - keysToFetch: The keys (properties) to retrieve for each contact (defaults to required keys).
    /// - Throws: An error if the fetch fails.
    /// - Returns: An array of fetched unified contacts matching the predicate.
    public func unifiedContacts(
        matching predicate: NSPredicate,
        keysToFetch keys: [CNKeyDescriptor] = [CNContactVCardSerialization.descriptorForRequiredKeys()]
    ) throws -> [CNContact] {
        return try store.unifiedContacts(matching: predicate, keysToFetch: keys)
    }
    
    // MARK: - Methods for adding, updating, and deleting contacts
    
    /// Adds a new contact to the store optionally specifying a container identifier.
    ///
    /// - Parameters:
    ///   - cnContact: The contact to add.
    ///   - identifier: The identifier of the container to add the contact to (optional).
    /// - Throws: An error if the contact cannot be added.
    public func add(_ cnContact: CNMutableContact, toContainerWithIdentifier identifier: String? = nil) throws {
        let request: CNSaveRequest = Self.makeCNSaveRequest()
        request.add(cnContact, toContainerWithIdentifier: identifier)
        try store.execute(request)
    }
    
    /// Updates an existing contact in the store.
    ///
    /// - Parameter cnContact: The contact to update.
    /// - Throws: An error if the contact cannot be updated.
    public func update(_ cnContact: CNMutableContact) throws {
        let request: CNSaveRequest = Self.makeCNSaveRequest()
        request.update(cnContact)
        try store.execute(request)
    }
    
    /// Deletes a contact from the store.
    ///
    /// - Parameter cnContact: The contact to delete.
    /// - Throws: An error if the contact cannot be deleted.
    public func delete(_ cnContact: CNMutableContact) throws {
        let request: CNSaveRequest = Self.makeCNSaveRequest()
        request.delete(cnContact)
        try store.execute(request)
    }
}
