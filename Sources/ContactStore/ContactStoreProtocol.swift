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
//  ContactStoreProtocol.swift
//
//
//  Created by Mykhailo Bondarenko on 26.03.2024.
//

import Contacts

/// A protocol defining essential methods for interacting with a contact store.
public protocol ContactStoreProtocol {
    /// Retrieves the current authorization status for accessing contacts.
    ///
    /// - Returns: The current authorization status.
    func authorizationStatus() -> CNAuthorizationStatus
    
    /// Requests authorization to access contacts.
    ///
    /// - Returns: `true` if authorization was granted, `false` otherwise.
    /// - Throws: An error if the request fails.
    func requestAccess() async throws -> Bool
    
    /// Fetches contacts from the store based on specified parameters.
    /// This function should be called on a background thread to avoid blocking the UI,
    /// especially when the contact database contains a large number of entries.
    ///
    /// - Parameters:
    ///   - keys: The keys to fetch for each contact.
    ///   - order: The order in which to sort the results.
    ///   - unifyResults: Whether to unify contact records from multiple sources.
    /// - Returns: An array of fetched contacts.
    /// - Throws: An error if the fetch fails.
    func fetch(
        keysToFetch keys: [CNKeyDescriptor],
        order: CNContactSortOrder,
        unifyResults: Bool
    ) throws -> [CNContact]
    
    /// Fetches contacts from the store based on a predicate.
    ///
    /// - Parameters:
    ///   - predicate: The predicate to filter contacts.
    ///   - keys: The keys to fetch for each contact.
    /// - Returns: An array of fetched contacts.
    /// - Throws: An error if the fetch fails.
    func fetch(
        by predicate: NSPredicate,
        keysToFetch keys: [CNKeyDescriptor]
    ) throws -> [CNContact]
    
    /// Fetches contacts from the store by name.
    ///
    /// - Parameters:
    ///   - name: The name to search for.
    ///   - keys: The keys to fetch for each contact.
    /// - Returns: An array of fetched contacts.
    /// - Throws: An error if the fetch fails.
    func fetch(
        by name: String,
        keysToFetch keys: [CNKeyDescriptor]
    ) throws -> [CNContact]
    
    /// Fetches a unified contact with the specified identifier.
    ///
    /// - Parameters:
    ///   - identifier: The identifier of the contact to fetch.
    ///   - keys: The keys to fetch for the contact.
    /// - Returns: The fetched unified contact.
    /// - Throws: An error if the fetch fails.
    func unifiedContact(
        withIdentifier identifier: String,
        keysToFetch keys: [CNKeyDescriptor]
    ) throws -> CNContact
    
    /// Fetches unified contacts matching a predicate.
    ///
    /// - Parameters:
    ///   - predicate: The predicate to filter contacts.
    ///   - keys: The keys to fetch for each contact.
    /// - Returns: An array of fetched unified contacts.
    /// - Throws: An error if the fetch fails.
    func unifiedContacts(
        matching predicate: NSPredicate,
        keysToFetch keys: [CNKeyDescriptor]
    ) throws -> [CNContact]
    
    /// Adds a new contact to the store.
    ///
    /// - Parameters:
    ///   - cnContact: The contact to add.
    ///   - identifier: The identifier of the container to add the contact to, if applicable.
    /// - Throws: An error if the contact cannot be added.
    func add(_ cnContact: CNMutableContact, toContainerWithIdentifier identifier: String?) throws
    
    /// Updates an existing contact in the store.
    ///
    /// - Parameter cnContact: The contact to update.
    /// - Throws: An error if the contact cannot be updated.
    func update(_ cnContact: CNMutableContact) throws
    
    /// Deletes a contact from the store.
    ///
    /// - Parameter cnContact: The contact to delete.
    /// - Throws: An error if the contact cannot be deleted.
    func delete(_ cnContact: CNMutableContact) throws
}
