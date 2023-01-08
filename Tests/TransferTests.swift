//
//  TransferTests.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

@testable import GroutLib
import XCTest

final class TransferTests: TestBase {
    var mainStore: NSPersistentStore!
    var archiveStore: NSPersistentStore!

    let routineArchiveID = UUID()
    let exerciseArchiveID = UUID()

    override func setUpWithError() throws {
        try super.setUpWithError()

        guard let mainURL = PersistenceManager.stores[.main]?.url,
              let archiveURL = PersistenceManager.stores[.archive]?.url,
              let psc = testContext.persistentStoreCoordinator,
              let mainStore = psc.persistentStore(for: mainURL),
              let archiveStore = psc.persistentStore(for: archiveURL)
        else {
            throw DataError.fetchError(msg: "Archive store not found")
        }

        self.mainStore = mainStore
        self.archiveStore = archiveStore
    }

    func testRoutine() throws {
        _ = ZRoutine.create(testContext, routineName: "blah", routineArchiveID: routineArchiveID, inStore: mainStore)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: archiveStore))

        try transferToArchive(testContext)
        try testContext.save()

        XCTAssertNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: archiveStore))
    }

    func testRoutineWithRoutineRun() throws {
        let startedAt = Date()
        let duration: TimeInterval = 30.0
        let sr = ZRoutine.create(testContext, routineName: "blah", routineArchiveID: routineArchiveID, inStore: mainStore)
        _ = ZRoutineRun.create(testContext, zRoutine: sr, startedAt: startedAt, duration: duration)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, forArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore))

        XCTAssertNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNil(try ZRoutineRun.get(testContext, forArchiveID: routineArchiveID, startedAt: startedAt, inStore: archiveStore))

        try transferToArchive(testContext)
        try testContext.save()

        XCTAssertNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNil(try ZRoutineRun.get(testContext, forArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore))

        XCTAssertNotNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, forArchiveID: routineArchiveID, startedAt: startedAt, inStore: archiveStore))
    }

    func testRoutineWithExercise() throws {
        let sr = ZRoutine.create(testContext, routineName: "blah", routineArchiveID: routineArchiveID, inStore: mainStore)
        _ = ZExercise.create(testContext, zRoutine: sr, exerciseName: "bleh", exerciseArchiveID: exerciseArchiveID)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZExercise.get(testContext, forArchiveID: exerciseArchiveID, inStore: mainStore))

        XCTAssertNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNil(try ZExercise.get(testContext, forArchiveID: exerciseArchiveID, inStore: archiveStore))

        try transferToArchive(testContext)
        try testContext.save()

        XCTAssertNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNil(try ZExercise.get(testContext, forArchiveID: exerciseArchiveID, inStore: mainStore))

        XCTAssertNotNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZExercise.get(testContext, forArchiveID: exerciseArchiveID, inStore: archiveStore))
    }

    func testRoutineWithExerciseAndExerciseRun() throws {
        let completedAt = Date()
        let intensity: Float = 30.0
        let sr = ZRoutine.create(testContext, routineName: "blah", routineArchiveID: routineArchiveID, inStore: mainStore)
        let se = ZExercise.create(testContext, zRoutine: sr, exerciseName: "bleh", exerciseArchiveID: exerciseArchiveID)
        _ = ZExerciseRun.create(testContext, zExercise: se, completedAt: completedAt, intensity: intensity)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZExercise.get(testContext, forArchiveID: exerciseArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZExerciseRun.get(testContext, forArchiveID: exerciseArchiveID, completedAt: completedAt, inStore: mainStore))

        try transferToArchive(testContext)
        try testContext.save()

        XCTAssertNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNil(try ZExercise.get(testContext, forArchiveID: exerciseArchiveID, inStore: mainStore))
        XCTAssertNil(try ZExerciseRun.get(testContext, forArchiveID: exerciseArchiveID, completedAt: completedAt, inStore: mainStore))

        XCTAssertNotNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZExercise.get(testContext, forArchiveID: exerciseArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZExerciseRun.get(testContext, forArchiveID: exerciseArchiveID, completedAt: completedAt, inStore: archiveStore))
    }
}