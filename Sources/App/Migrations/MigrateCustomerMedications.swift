//
//  MigrateCustomerMedications.swift
//  
//
//  Created by Justin Honda on 5/8/22.
//

import Fluent
import Vapor

struct MigrateCustomerMedications: Migration {

    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("customerMedications")
            .id()
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("customerMedications").delete()
    }

}
