import Foundation
import MacrosDemo

let ffg = #doubleValue(3)

// MARK: - sss

#generateStruct(
    "UserModels",
    fields: [
        "name": "String"
    ]
)
