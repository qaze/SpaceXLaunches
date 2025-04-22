@testable import SpaceXLaunches
import Foundation

class MockLaunchService: LaunchService {
    var mockResult: [Launch]?
    var mockError: Error?
    var onFetch: (() -> Void)?
    
    func fetchAll() async throws -> [Launch] {
        onFetch?()
        
        if let error = mockError {
            throw error
        }
        
        return mockResult ?? []
    }
} 
