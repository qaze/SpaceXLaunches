@testable import SpaceXLaunches
import Foundation

final class MockCacheService: CacheService {
    var mockResult: Any?
    var mockFetchError: Error?
    var mockSaveError: Error?
    private(set) var savedObject: Any?
    private(set) var savedPath: CachePath?
    private(set) var loadedPath: CachePath?
    
    func save<T: Encodable>(_ data: T, to path: CachePath) throws {
        if let error = mockSaveError {
            throw error
        }
        savedObject = data
        savedPath = path
    }
    
    func load<T: Decodable>(from path: CachePath) throws -> T {
        if let error = mockFetchError {
            throw error
        }
        
        loadedPath = path
        
        guard let result = mockResult as? T else {
            throw NSError(domain: "test", code: 2)
        }
        
        return result
    }
} 
