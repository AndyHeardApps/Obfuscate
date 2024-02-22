import Foundation
import Obfuscate

let explicitKeyValue = #obfuscate("1873g97ybf087t31gb", key: "PapYT8nL1T4EJQPxejHdf0D8yUzJ75UTEcu5A83zoBU=")
let keyBase64 = "PapYT8nL1T4EJQPxejHdf0D8yUzJ75UTEcu5A83zoBU="
assert(try! explicitKeyValue(keyBase64) == "1873g97ybf087t31gb")

let generatedKeyValue = #obfuscate("8207hqpofbgf9-g3gbu")
assert(generatedKeyValue == "8207hqpofbgf9-g3gbu")
