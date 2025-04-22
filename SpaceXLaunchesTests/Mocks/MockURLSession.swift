@testable import SpaceXLaunches
import Foundation

class MockURLSession: Session {
    var data: Data = Data()
    var response: URLResponse?
    var error: Error?
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = error {
            throw error
        }
        return (data, response!)
    }
} 
