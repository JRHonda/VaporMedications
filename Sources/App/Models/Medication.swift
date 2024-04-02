//
//  Medication.swift
//  
//
//  Created by Justin Honda on 5/8/22.
//

import Fluent
import Vapor

final class Medication: Model, Content {

    static let schema: String = "medications"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Parent(key: "customerMedicationID")
    var customerMedication: CustomerMedication

    init() { }

    init(id: UUID? = nil, name: String, customerMedicationID: CustomerMedication.IDValue) {
        self.name = name
        self.$customerMedication.id = customerMedicationID
    }

}
