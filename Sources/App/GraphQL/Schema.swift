//
//  Schema.swift
//  
//
//  Created by Justin Honda on 5/8/22.
//

import Graphiti
import Vapor

let schema = try! Schema<Resolver, Request> {

    // Since UUID is not a built-in type in GraphQL,
    // you have to declare it separately in the schema as a Scalar
    Scalar(UUID.self)

    /// Must be before `CustomerMedication` query
    Type(Medication.self) {
        Field("id", at: \.id)
        Field("name", at: \.name)
    }

    Type(CustomerMedication.self) {
        Field("id", at: \.id)
        Field("medications", at: \.medications)
    }

    Query {
        Field("customerMedications", at: Resolver.getCustomerMedications)
    }

    Mutation {
        Field("createCustomerMedication", at: Resolver.createCustomerMedication) { }

        Field("createMedication", at: Resolver.createMedication) {
            Argument("name", at: \.name)
            Argument("customerMedicationID", at: \.customerMedicationID)
        }

        Field("updateMedication", at: Resolver.updateMedication) {
            Argument("medicationID", at: \.medicationID)
            Argument("name", at: \.name)
        }

        Field("deleteMedication", at: Resolver.deleteMedication) {
            Argument("medicationID", at: \.medicationID)
        }
    }

}
