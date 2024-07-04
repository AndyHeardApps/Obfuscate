import Testing
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport

@Suite(.enabled(if: MacroTesting.shared.isEnabled))
struct ObfuscateTests {}

// MARK: - Tests
extension ObfuscateTests {
    
    @Test("Explicit key")
    func explicitKey() {
        assertMacroExpansion(
            """
            let decryptedValue = #obfuscate("value", key: "PapYT8nL1T4EJQPxejHdf0D8yUzJ75UTEcu5A83zoBU=")
            """,
            expandedSource: """
            let decryptedValue = { (keyBase64: String) throws -> String in
                let encryptedData = Data([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 247, 220, 184, 189, 120, 228, 28, 46, 166, 158, 21, 101, 211, 80, 39, 24, 220, 119, 44, 193, 75])

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
            """,
            macros: MacroTesting.shared.testMacros
        )
    }
    
    @Test("Generated key")
    func generatedKey() {
        assertMacroExpansion(
            """
            let decryptedValue = #obfuscate("value")
            """,
            expandedSource: """
            let decryptedValue = {
                let data = Data([32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 164, 91, 202, 5, 9, 206, 105, 26, 145, 182, 6, 163, 39, 99, 103, 76, 159, 82, 168, 211, 243])
                let keyData = Data([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31])
                let key = SymmetricKey(data: keyData)

                let decryptedData = try! AES.GCM.open(.init(combined: data), using: key)

                return String(data: decryptedData, encoding: .utf8)!
            }()
            """,
            macros: MacroTesting.shared.testMacros
        )
    }
}
