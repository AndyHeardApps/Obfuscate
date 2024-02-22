// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
@_exported import CryptoKit

/**
 Obfuscates the provided `String` by AES encrypting it using a randomly generated key.
 
 When calling this macro, the provided `String` value is encrypted and stored in code as an array of bytes, alongside the bytes of the key used to encrypt it. When called, the key is used to decrypt the bytes and return the original `String`.
 
 Storing secrets in this way makes it harder for attackers to extract them by looking for `String` in the app binary.
 
 - Parameter string: The `String` literal value to be obfuscated.
 */
@freestanding(expression)
public macro obfuscate(_ string: StaticString) -> String = #externalMacro(module: "ObfuscateMacros", type: "ObfuscateMacro")

/**
 Obfuscates the provided `String` by AES encrypting it using  the provided `SymmetricKey` Base-64 representation.
 
 When calling this macro, the provided `String` value is encrypted using the providedkey and stored in code as an array of bytes, and the assigned variable becomes a `(String) throws -> String` closure.
 
 To decrypt and return the original value, call the closure a runtime, passing in the same key Base-64 encoded `String` that was used to encrypt the value originally.
 
 This allows the key used to encrypt the secret to be store outside of the app binary, perhaps on a server.
 
 Storing secrets in this way makes it harder for attackers to extract them by looking for `String` in the app binary, or by decompiling the app and finding the encrypted data and encrypting key.
 */
@freestanding(expression)
public macro obfuscate(_ string: StaticString, key: StaticString) -> (String) throws -> String = #externalMacro(module: "ObfuscateMacros", type: "ObfuscateMacro")
