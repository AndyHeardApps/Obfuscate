import SwiftSyntaxMacros
#if canImport(ObfuscateMacros)
@testable import ObfuscateMacros
#endif

struct MacroTesting {
    
    // MARK: - Static properties
    static let shared = MacroTesting()
    
    // MARK: - Properties
    let testMacros: [String : Macro.Type]
    let isEnabled: Bool
    
    // MARK: - Initializer
    private init() {
        
        #if canImport(ObfuscateMacros)
        self.testMacros = [
            "obfuscate" : ObfuscateMacro.self
        ]
        self.isEnabled = true
        ObfuscateMacro.randomNumberGeneratorStore.generator = MockRandomNumberGenerator()
        #else
        self.testMacros = [:]
        self.isEnabled = false
        #endif
    }
}
