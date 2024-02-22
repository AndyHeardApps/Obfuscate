import Foundation

/// Errors that may be thrown by the `#obfuscate(_, key: _)` macro when decrypting the obfuscated value.
public enum ObfuscateError: Error {
    
    // MARK: - Cases
    
    /// The provided base Base-64 cannot be turned in to `Data`.
    case invalidKeyBase64
    
    /// The decrypted data cannot be turned into a `String` using `.utf8` encoding.
    case invalidDecryptedValueData
}
