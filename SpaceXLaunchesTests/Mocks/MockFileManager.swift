@testable import SpaceXLaunches
import Foundation

class MockFileManager: FileManagerProtocol {
    var mockCachesURL: URL!
    
    func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
        return [mockCachesURL]
    }
    
    func fileExists(atPath path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
    
    func removeItem(at URL: URL) throws {
        try FileManager.default.removeItem(at: URL)
    }
}
