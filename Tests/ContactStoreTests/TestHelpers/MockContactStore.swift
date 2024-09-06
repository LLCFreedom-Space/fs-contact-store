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
//  MockContactStore.swift
//
//
//  Created by Mykhailo Bondarenko on 26.03.2024.
//

import Contacts

/// A mock implementation of CNContactStore for testing purposes.
final class MockContactStore: CNContactStore {
    /// An array of mock contacts stored in the store.
    var contacts: [CNContact] = []
    /// An error to be thrown by certain methods for simulating failures.
    var error: Error?
    
    // MARK: - Overridden methods for mocking behavior
    
    /// Grants access automatically for testing purposes.
    ///
    /// - Parameter entityType: The type of entity to request access for (ignored).
    /// - Throws: An error if set in `error`.
    /// - Returns: Always returns `true`.
    override func requestAccess(for entityType: CNEntityType) async throws -> Bool {
        if let error = error {
            throw error
        }
        return true
    }
    
    /// Enumerates mock contacts based on the fetch request.
    ///
    /// - Parameters:
    ///   - fetchRequest: The fetch request specifying filtering and sorting criteria.
    ///   - block: The block called for each enumerated contact.
    /// - Throws: An error if set in `error` or no contacts are found.
    override func enumerateContacts(
        with fetchRequest: CNContactFetchRequest,
        usingBlock block: (
            CNContact,
            UnsafeMutablePointer<ObjCBool>
        ) -> Void
    ) throws {
        contacts.append(contact)
        if error != nil {
            throw CNError(.validationMultipleErrors)
        } else if contacts.isEmpty {
            throw CNError(.recordDoesNotExist)
        }
        
        guard let contact = contacts.first else {
            return
        }
        var pointer: ObjCBool = false
        block(contact, &pointer)
    }
    
    /// Executes a mock save request by adding, updating, or deleting contacts.
    ///
    /// - Parameter saveRequest: The save request containing the actions to perform.
    /// - Throws: An error if the request type is not supported.
    override func execute(_ saveRequest: CNSaveRequest) throws {
        guard let request = saveRequest as? MockCNSaveRequest else {
            throw NSError(
                domain: "MockContactStoreError",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Unsupported save request type"]
            )
        }
        if let contact = request.addedContact {
            contacts.append(contact)
        } else if let contact = request.updatedContact {
            contacts.removeAll { $0.identifier == contact.identifier }
            contacts.append(contact)
        } else if let contact = request.deletedContact {
            contacts.removeAll { $0.identifier == contact.identifier }
        }
    }
    
    /// Fetches a single mock contact by its identifier.
    ///
    /// - Parameters:
    ///   - identifier: The identifier of the contact to fetch.
    ///   - keysToFetch: The keys (properties) to retrieve for the contact (ignored).
    /// - Throws: An error if the contact is not found or if set in `error`.
    override func unifiedContact(withIdentifier identifier: String, keysToFetch keys: [any CNKeyDescriptor]) throws -> CNContact {
        guard let contact = contacts.first(where: { $0.identifier == identifier }) else {
            if let error = error {
                throw error
            } else {
                throw CNError(.recordDoesNotExist)
            }
        }
        return contact
    }
    
    /// Fetches mock contacts matching a predicate.
    ///
    /// - Parameters:
    ///   - predicate: The predicate to filter contacts.
    ///   - keysToFetch: The keys (properties) to retrieve for each contact (ignored).
    /// - Throws: An error if set in `error`.
    /// - Returns: An array of mock contacts matching the predicate.
    override func unifiedContacts(matching predicate: NSPredicate, keysToFetch keys: [any CNKeyDescriptor]) throws -> [CNContact] {
        if let error = error {
            throw error
        }
        
        let name = predicate.value(forKey: "name")
        let result = contacts.filter { $0.givenName == name as? String || $0.familyName == name as? String }
        return result
    }
    
    // MARK: - Sample contact for testing purposes
    
    /// A sample `CNMutableContact` instance with various properties populated.
    let contact = {
        let contact = CNMutableContact()
        contact.givenName = "John"
        contact.middleName = "Halk"
        contact.familyName = "Doe"
        contact.departmentName = "Finance"
        contact.jobTitle = "Manager"
        contact.namePrefix = "Mr."
        contact.nameSuffix = "Jr."
        contact.nickname = "Tester"
        contact.organizationName = "Wallstreet"
        contact.phoneticFamilyName = "Do"
        contact.phoneticMiddleName = "Helk"
        contact.phoneticGivenName = "Jon"
        contact.previousFamilyName = "Holk"
        contact.emailAddresses = [
            CNLabeledValue(label: "email_label1", value: "some@mail.com"),
            CNLabeledValue(label: "email_label2", value: "another@mail.com")
        ]
        contact.phoneNumbers = [
            CNLabeledValue(label: "_$!<Home>!$_", value: CNPhoneNumber(stringValue: "+380981112233")),
            CNLabeledValue(label: "phone_label2", value: CNPhoneNumber(stringValue: "+380503332211"))
        ]
        contact.instantMessageAddresses = [
            CNLabeledValue(label: "insta_label1", value: CNInstantMessageAddress(username: "user", service: "twitter")),
            CNLabeledValue(label: "insta_label2", value: CNInstantMessageAddress(username: "admin", service: "facebook"))
        ]
        
        contact.urlAddresses = [
            CNLabeledValue(label: "url_label1", value: "http://tesla.com"),
            CNLabeledValue(label: "url_label2", value: "http://apple.com")
        ]
        
        contact.socialProfiles = [
            CNLabeledValue(
                label: "social_label1",
                value: CNSocialProfile(
                    urlString: nil,
                    username: "bloger",
                    userIdentifier: nil,
                    service: "Instagram"
                )
            ),
            CNLabeledValue(
                label: "social_label2",
                value: CNSocialProfile(
                    urlString: nil,
                    username: "bloger",
                    userIdentifier: nil,
                    service: "Instagram"
                )
            )
        ]
        return contact
    }()
}
