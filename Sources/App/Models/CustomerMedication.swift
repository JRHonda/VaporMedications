//
//  CustomerMedication.swift
//  
//
//  Created by Justin Honda on 5/8/22.
//

import Fluent
import Vapor

final class CustomerMedication: Model, Content {

    static let schema: String = "customerMedications"

    @ID(key: .id)
    var id: UUID?

    @Children(for: \.$customerMedication)
    var medications: [Medication]

    init() { }

}
