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
