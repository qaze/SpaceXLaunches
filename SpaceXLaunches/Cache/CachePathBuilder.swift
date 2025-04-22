import Foundation

protocol CachePathBuilder {
    func makeFileURL(for path: CachePath) -> URL
}

struct CachePathBuilderImpl: CachePathBuilder {
    private let fileManager: FileManagerProtocol
    
    init(fileManager: FileManagerProtocol) {
        self.fileManager = fileManager
    }
    
    func makeFileURL(for path: CachePath) -> URL {
        let folder = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return folder.appendingPathComponent(buildFileName(for: path))
    }
    
    private func buildFileName(for path: CachePath) -> String {
        switch path {
        case .launches:
            return "launches_cache.json"
        case let .rocket(id):
            return "rockets_\(id)_cache.json"
        }
    }
}
