//
//  Exercise.swift
//
// Copyright 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

@objc(Exercise)
public class Exercise: NSManagedObject {}

extension Exercise: UserOrdered {}

/// Struct providing archivable reference to the managed object.
/// Codable for use in NavigationStack, State, and UserActivity.
/// Identifiable for use in .sheet and .fullScreenCover.
/// RawRepresentable so that it can be stored in SceneStorage or AppStorage.
/// Typed to Exercise for use as a navigationDestination.
public typealias ExerciseUriRep = UriRep<Exercise>
public extension Exercise {
    var uriRep: ExerciseUriRep {
        UriRep(value: uriRepresentation)
    }
}

public extension Exercise {
    // NOTE: does NOT save to context
    static func create(_ context: NSManagedObjectContext, userOrder: Int16) -> Exercise {
        let nu = Exercise(context: context)
        nu.userOrder = userOrder
        nu.name = "New Exercise"
        return nu
    }
    
    static func get(_ context: NSManagedObjectContext, forURIRepresentation url: URL) -> Exercise? {
        NSManagedObject.get(context, forURIRepresentation: url) as? Exercise
    }

    // @NSManaged public var name: String?
    var wrappedName: String {
        get { name ?? "unknown" }
        set { name = newValue }
    }
}
