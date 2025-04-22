import Foundation

protocol FileManagerProtocol {
    func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL]
    func fileExists(atPath path: String) -> Bool
    func removeItem(at URL: URL) throws
}

extension FileManager: FileManagerProtocol {} 