import Foundation
@testable import SpaceXLaunches

final class MockURLRequestBuilder: URLRequestBuilder {
    var mockURLRequest: URLRequest = URLRequest(url: URL(string: "https://example.com")!)
    func makeUrlRequest(for endpoint: Endpoint) throws -> URLRequest {
        mockURLRequest
    }
}
