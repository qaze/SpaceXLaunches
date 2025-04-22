@testable import SpaceXLaunches
import Foundation

class MockRocketService: RocketService {
    var mockResult: Rocket?
    var mockError: Error?
    var onFetch: ((String) -> Void)?
    
    func fetch(by id: String) async throws -> Rocket {
        onFetch?(id)
        
        if let error = mockError {
            throw error
        }
        
        return mockResult!
    }
} 
