import Foundation

protocol Session {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: Session {}
