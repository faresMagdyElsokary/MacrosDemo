import Foundation
import MacrosDemo

let ffg = #doubleValue(3)

//#generateStruct("UserModel", fields: ["x": "Int"])


@Singleton
class Single {
    let x = 1
}
