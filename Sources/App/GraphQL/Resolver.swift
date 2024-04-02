//
//  Resolver.swift
//  
//
//  Created by Justin Honda on 5/8/22.
//

import Foundation
import Graphiti
import Vapor

/**
 It's important to note that currently (as of 5/8/2022) the `Resolver` below works within the context of a single user. So it's as
 if the CID (Customer Identifier - passed via headers) has already been verified and filtered on.
 TODO - Pass in CID via headers to filter out correct `CustomerMedication`.

 ```
 query GetMedications {
   customerMedications {
     medications {
       name
     }
   }
 }
 ```

 */

// MARK: - CustomerMedication resolvers

final class Resolver {

    // MARK: - GET

    /// Retrieve a `CustomerMedication` and their `Medication`s
    /// - Parameters:
    ///   - req: Incoming HTTP request
    ///   - arguments: This method takes `NoArgument`s, a type offered by `Graphiti`.
    /// - Returns: A list of `CustomerMedication`s
    func getCustomerMedications(_ req: Request, arguments: NoArguments) throws -> EventLoopFuture<CustomerMedication> {

        // NOTE: Just getting the first one to be able to directly mock the `GetMedications`
        // currently in production for Medications Plugin
        // TODO: - Implement passing CID in via headers to filter on correct user
        CustomerMedication.query(on: req.db)
            .with(\.$medications)
            .first()
            .unwrap(or: Abort(.notFound))
    }

    // MARK: - POST

    /// Creates a new `CustomerMedication` with an empty list of `Medication`s
    /// - Parameters:
    ///   - req: Incoming HTTP request
    ///   - arguments: This method takes `NoArguments`, a type offered by `Graphiti`.
    /// - Returns: The `CustomerMedication` created with a unique UUID string
    func createCustomerMedication(_ req: Request, arguments: NoArguments) throws -> EventLoopFuture<CustomerMedication> {

        let customerMedication = CustomerMedication()
        return customerMedication.create(on: req.db)
            .map { customerMedication }
    }

}

// MARK: - Medication resolvers

extension Resolver {

    // MARK: - POST

    struct CreateMedicationArguments: Codable {
        let name: String
        let customerMedicationID: String
    }

    /// Creates a new `Medication` for a specific `CustomerMedication`.
    /// - Parameters:
    ///   - req: Incoming HTTP request
    ///   - arguments: This method takes `CreateMedicationArguments`
    /// - Returns: The `Medication` created.
    func createMedication(_ req: Request, arguments: CreateMedicationArguments) throws -> EventLoopFuture<Medication> {

        guard let customerMedicationID = UUID(uuidString: arguments.customerMedicationID) else {
            throw Abort(.badRequest, reason: "Malformed UUID string -> \(arguments.customerMedicationID)")
        }

        let medication = Medication(name: arguments.name,
                                    customerMedicationID: customerMedicationID)

        return medication.create(on: req.db)
            .map { medication }
    }

    struct UpdateMedicationArguments: Codable {
        let medicationID: String
        let name: String
    }

    /// Handler for updating an existing `Medication`
    /// - Parameters:
    ///   - req: Incoming HTTP request
    ///   - arguments: This method takes `UpdateMedicationArguments`
    /// - Returns: The updated `Medication`
    func updateMedication(_ req: Request, arguments: UpdateMedicationArguments) throws -> EventLoopFuture<Medication> {

        guard let medicationID = UUID(uuidString: arguments.medicationID) else {
            throw Abort(.badRequest, reason: "Malformed UUID string -> \(arguments.medicationID)")
        }

        return Medication.find(medicationID, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { medication in
                medication.name = arguments.name
                return medication.update(on: req.db)
                    .map { medication }
            }
    }

    // MARK: - DELETE

    struct DeleteMedicationArguments: Codable {
        let medicationID: String
    }

    func deleteMedication(_ req: Request, arguments: DeleteMedicationArguments) throws -> EventLoopFuture<Bool> {

        guard let medicationID = UUID(uuidString: arguments.medicationID) else {
            throw Abort(.badRequest, reason: "Malformed UUID string -> \(arguments.medicationID)")
        }

        return Medication.find(medicationID, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: true)
    }

}
