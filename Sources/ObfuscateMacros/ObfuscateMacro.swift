import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics
import CryptoKit

public struct ObfuscateMacro: ExpressionMacro {
    
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        
        let arguments = try Self.arguments(in: node)

        if let key = arguments.key {
            return try explicitKeyExpression(
                node: node,
                value: arguments.value,
                key: key
            )
        } else {
            return try generatedKeyExpression(
                node: node,
                value: arguments.value
            )
        }
    }
}

// MARK: - Arguments
extension ObfuscateMacro {
    
    private struct Arguments {
        let value: String
        let key: SymmetricKey?
    }
    
    private static func arguments(in node: some FreestandingMacroExpansionSyntax) throws -> Arguments {
        
        guard 
            let value = node.argumentList.first?
                .expression
                .as(StringLiteralExprSyntax.self)?
                .representedLiteralValue
        else {
            throw DiagnosticsError(diagnostics: [
                .init(
                    node: node,
                    message: DiagnosticMessage.missingValueArgument
                )
            ])
        }
        
        let key: SymmetricKey?
        if
            node.argumentList.last?.label?.text == "key",
            let keyBase64 = node.argumentList.last?
                .expression
                .as(StringLiteralExprSyntax.self)?
                .representedLiteralValue
        {
            guard let keyData = Data(base64Encoded: keyBase64) else {
                throw DiagnosticsError(diagnostics: [
                    .init(
                        node: node,
                        message: DiagnosticMessage.invalidKeyBase64
                    )
                ])
            }
            key = SymmetricKey(data: keyData)
        } else {
            key = nil
        }
        
        return .init(
            value: value,
            key: key
        )
    }
}

// MARK: - Explicit key
extension ObfuscateMacro {
    
    static var randomNumberGenerator: RandomNumberGenerator = SystemRandomNumberGenerator()
    
    private static func generatedKeyExpression(
        node: some FreestandingMacroExpansionSyntax,
        value: String
    ) throws -> ExprSyntax {
        
        let key = SymmetricKey(data: Data(size: 32, using: &randomNumberGenerator))
        let keyBytes = key.withUnsafeBytes { [UInt8]($0) }
        
        let encryptedBytes = try encryptedBytes(
            node: node,
            value: value,
            key: key
        )

        return """
        {
            let data = Data(\(raw: encryptedBytes))
            let keyData = Data(\(raw: keyBytes))
            let key = SymmetricKey(data: keyData)
        
            let decryptedData = try! AES.GCM.open(.init(combined: data), using: key)
        
            return String(data: decryptedData, encoding: .utf8)!
        }()
        """
    }
}

// MARK: - Explicit key
extension ObfuscateMacro {
    
    private static func explicitKeyExpression(
        node: some FreestandingMacroExpansionSyntax,
        value: String,
        key: SymmetricKey
    ) throws -> ExprSyntax {
        
        let encryptedBytes = try encryptedBytes(
            node: node,
            value: value,
            key: key
        )
        
        return """
        { (keyBase64: String) throws -> String in
            let encryptedData = Data(\(raw: encryptedBytes))
        
            guard let keyData = Data(base64Encoded: keyBase64) else {
                throw ObfuscateError.invalidKeyBase64
            }
            let key = SymmetricKey(data: keyData)
        
            let decryptedData = try AES.GCM.open(.init(combined: encryptedData), using: key)
        
            guard let decryptedValue = String(data: decryptedData, encoding: .utf8) else {
                throw ObfuscateError.invalidDecryptedValueData
            }
        
            return decryptedValue
        }
        """
    }
}

// MARK: - Encryption
extension ObfuscateMacro {
    
    private static func encryptedBytes(
        node: some FreestandingMacroExpansionSyntax,
        value: String,
        key: SymmetricKey
    ) throws -> [UInt8] {
        
        let encryptedData: Data?
        do {
            encryptedData = try AES.GCM.seal(
                Data(value.utf8),
                using: key,
                nonce: .init(data: Data(size: 12, using: &randomNumberGenerator))
            ).combined
        } catch {
            throw DiagnosticsError(diagnostics: [
                .init(
                    node: node,
                    message: DiagnosticMessage.encryptionFailed(error)
                )
            ])
        }
        
        guard let encryptedData else {
            throw DiagnosticsError(diagnostics: [
                .init(
                    node: node,
                    message: DiagnosticMessage.invalidEncryptedData
                )
            ])
        }

        let encryptedBytes = [UInt8](encryptedData)
        
        return encryptedBytes
    }
}

// MARK: - Diagnostic
extension ObfuscateMacro {
    
    fileprivate enum DiagnosticMessage {
        
        case missingValueArgument
        case invalidKeyBase64
        case encryptionFailed(Error)
        case invalidEncryptedData
    }
}

extension ObfuscateMacro.DiagnosticMessage: DiagnosticMessage {
    
    var message: String {
        
        switch self {
        case .missingValueArgument:
            "Missing argument for value"
            
        case .invalidKeyBase64:
            "Provided key is invalid Base-64 encoded string"
            
        case let .encryptionFailed(error):
            "Failed initial encryption of value: \(error)"
            
        case .invalidEncryptedData:
            "Encrypted data was invalid or missing"
            
        }
    }
    
    private var messageID: String {
        
        switch self {
        case .missingValueArgument:
            "missingValueArgument"
            
        case .invalidKeyBase64:
            "invalidKeyBase64"
            
        case .encryptionFailed:
            "encryptionFailed"
            
        case .invalidEncryptedData:
            "invalidEncryptedData"
            
        }
    }
    
    var diagnosticID: MessageID {
        
        .init(domain: "ObfuscateMacro", id: messageID)
    }
    
    var severity: DiagnosticSeverity {
        
        switch self {
        case .missingValueArgument, .invalidKeyBase64, .encryptionFailed, .invalidEncryptedData:
            .error
            
        }
    }
}
