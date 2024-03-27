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
//  MockCNSaveRequest.swift
//
//
//  Created by Mykhailo Bondarenko on 27.03.2024.
//

import ContactStore

/// A mock implementation of CNSaveRequest for testing purposes.
final class MockCNSaveRequest: CNSaveRequest {
    /// A mock contact to be added.
    var addedContact: CNMutableContact?
    
    /// A mock contact to be updated.
    var updatedContact: CNMutableContact?
    
    /// A mock contact to be deleted.
    var deletedContact: CNMutableContact?
    
    /// Initializes a new MockCNSaveRequest.
    override init() {
        super.init()
    }
    
    // MARK: - Convenience initializers
    
    /// Convenience initializer for adding a new contact.
    ///
    /// - Parameter contact: The contact to add.
    convenience init(adding contact: CNMutableContact) {
        self.init()
        add(contact, toContainerWithIdentifier: nil)
    }
    
    /// Convenience initializer for updating an existing contact.
    ///
    /// - Parameter contact: The contact to update.
    convenience init(updating contact: CNMutableContact) {
        self.init()
        update(contact)
    }
    
    /// Convenience initializer for deleting a contact.
    ///
    /// - Parameter contact: The contact to delete.
    convenience init(deleting contact: CNMutableContact) {
        self.init()
        delete(contact)
    }
    
    // MARK: - Overridden methods for mocking behavior
    
    /// Records the contact to be added for testing purposes.
    ///
    /// - Parameter contact: The contact to add.
    override func add(_ contact: CNMutableContact, toContainerWithIdentifier identifier: String?) {
        self.addedContact = contact
    }
    
    /// Records the contact to be updated for testing purposes.
    ///
    /// - Parameter contact: The contact to update.
    override func update(_ contact: CNMutableContact) {
        self.updatedContact = contact
    }
    
    /// Records the contact to be deleted for testing purposes.
    ///
    /// - Parameter contact: The contact to delete.
    override func delete(_ contact: CNMutableContact) {
        self.deletedContact = contact
    }
}
