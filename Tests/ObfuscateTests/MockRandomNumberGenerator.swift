import Foundation

struct MockRandomNumberGenerator {
    
    // MARK: - Properties
    private var seed: UInt64 = 0
}

// MARK: - Random number generator
extension MockRandomNumberGenerator: RandomNumberGenerator {
    
    mutating func next() -> UInt64 {
        
        defer { seed += 1 }
        return seed
    }
}
