import Foundation

extension Data {

    init(
        size: Int, using
        generator: inout some RandomNumberGenerator
    ) {
        
        let bytes = (0..<size).map { _ in
            UInt8.random(
                in: UInt8.min...UInt8.max,
                using: &generator
            )
        }
        
        self = .init(bytes)
    }
}

final class RandomNumberGeneratorStore {
    
    // Properties
    private let lock = NSLock()
    private var _generator: any RandomNumberGenerator
    var generator: any RandomNumberGenerator {
        get {
            lock.withLock { _generator }
        }
        set {
            lock.withLock { _generator = newValue }
        }
    }
    
    // Initializer
    init() {
        self._generator = SystemRandomNumberGenerator()
    }
}
