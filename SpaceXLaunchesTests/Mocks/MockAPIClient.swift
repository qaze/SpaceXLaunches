@testable import SpaceXLaunches
import Foundation

final class MockAPIClient: APIClient {
    var mockResult: Any?
    var mockError: Error?
    
    func fetch<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        if let error = mockError {
            throw error
        }
        
        guard let result = mockResult as? T else {
            throw NSError(domain: "test", code: 2)
        }
        
        return result
    }
}
