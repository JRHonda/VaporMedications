//
//  MigrateMedications.swift
//  
//
//  Created by Justin Honda on 5/8/22.
//

import Fluent
import Vapor

struct MigrateMedications: Migration {

    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("medications")
            .id()
            .field("name", .string, .required)
            .field("customerMedicationID", .uuid, .references("customerMedications", "id"))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("medications").delete()
    }

}
