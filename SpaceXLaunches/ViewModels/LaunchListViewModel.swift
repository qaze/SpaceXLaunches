import Foundation

@MainActor
class LaunchListViewModel: ObservableObject {
    @Published private(set) var launches: [Launch] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    private let launchService: LaunchService
    
    init(launchService: LaunchService) {
        self.launchService = launchService
    }
    
    func fetchLaunches() async {
        isLoading = true
        error = nil
        
        do {
            launches = try await launchService.fetchAll()
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
} 
