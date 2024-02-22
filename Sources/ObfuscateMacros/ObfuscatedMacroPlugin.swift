import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct ObfuscatePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ObfuscateMacro.self,
    ]
}
