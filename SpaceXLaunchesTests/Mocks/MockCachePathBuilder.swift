import Foundation
@testable import SpaceXLaunches

final class MockCachePathBuilder: CachePathBuilder {
    var mockURL: URL = URL(fileURLWithPath: "mock/path")
    func makeFileURL(for path: CachePath) -> URL {
        return mockURL
    }
}
