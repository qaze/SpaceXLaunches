@testable import SpaceXLaunches
import Foundation

class MockJSONFileCoder: JSONFileCoder {
    var mockResult: Any?
    var mockError: Error?
    private(set) var encodedObject: Any?
    private(set) var encodedURL: URL?
    private(set) var decodedURL: URL?
    
    func encode<T: Encodable>(_ value: T, to url: URL) throws {
        if let error = mockError {
            throw error
        }
        encodedObject = value
        encodedURL = url
    }
    
    func decode<T: Decodable>(_ type: T.Type, from url: URL) throws -> T {
        if let error = mockError {
            throw error
        }
        decodedURL = url
        guard let result = mockResult as? T else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: [], debugDescription: "Mock result not set")
            )
        }
        return result
    }
} 
