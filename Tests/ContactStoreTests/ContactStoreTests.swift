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
//  ContactStoreTests.swift
//
//
//  Created by Mykhailo Bondarenko on 27.03.2024.
//

import XCTest
@testable import ContactStore

final class ContactStoreTests: XCTestCase {
    func testRequestAccess() async {
        do {
            let bool = try await store.requestAccess()
            XCTAssertTrue(bool)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testAuthorizationStatus() {
        XCTAssertEqual(ContactStore.shared.authorizationStatus(), CNAuthorizationStatus.authorized)
    }
    
    func testFetchContacts() async {
        do {
            let contacts = try await store.fetch()
            XCTAssertTrue(contacts.count == 1)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testFetchContactsError() async throws {
        let mockStore = MockContactStore()
        mockStore.error = CNError(.validationMultipleErrors)
        let store = ContactStore(store: mockStore)
        do {
            _ = try await store.fetch()
            XCTFail("Expected error not thrown")
        } catch {
            XCTAssertTrue(error is CNError) // Ensure a CNError is thrown
        }
    }
    
    func testAddContact() throws {
        let store = self.store
        let mockRequest = {
            return MockCNSaveRequest()
        }
        store.use(mockRequest)
        let contact = CNMutableContact()
        contact.givenName = "Paul"
        try store.add(contact)
        let contacts = try store.fetch(by: "Paul")
        XCTAssertTrue(contacts.count == 1)
        XCTAssertEqual(contact.givenName, contacts.first?.givenName)
    }
    
    func testUpdateContact() throws {
        let store = self.store
        let mockRequest = {
            return MockCNSaveRequest()
        }
        store.use(mockRequest)
        let contact = CNMutableContact()
        contact.givenName = "Paul"
        try store.add(contact)
        let addedContact = try store.unifiedContact(withIdentifier: contact.identifier)
        let copy = addedContact.mutableCopy() as! CNMutableContact
        copy.givenName = "John"
        try store.update(copy)
        let contacts = try store.fetch(by: "John")
        XCTAssertTrue(contacts.count == 1)
        XCTAssertEqual(copy.givenName, contacts.first?.givenName)
    }
    
    func testDeleteContact() throws {
        let store = self.store
        let mockRequest = {
            return MockCNSaveRequest()
        }
        store.use(mockRequest)
        let contact = CNMutableContact()
        contact.givenName = "Paul"
        try store.add(contact)
        let addedContact = try store.unifiedContact(withIdentifier: contact.identifier)
        let copy = addedContact.mutableCopy() as! CNMutableContact
        try store.delete(copy)
        let contacts = try store.fetch(by: "Paul")
        XCTAssertTrue(contacts.count == 0)
    }
}
