import Foundation

public extension SymmetricKey {
    
    /// The Base-64 encoded `String` of the key data.
    var base64EncodedString: String {
        withUnsafeBytes { Data($0).base64EncodedString() }
    }
}
