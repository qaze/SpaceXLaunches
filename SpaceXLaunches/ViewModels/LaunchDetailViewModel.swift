import Foundation

@MainActor
class LaunchDetailViewModel: ObservableObject {
    @Published private(set) var rocket: Rocket?
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    let launch: Launch
    private let rocketService: RocketService
    
    init(launch: Launch, rocketService: RocketService) {
        self.launch = launch
        self.rocketService = rocketService
    }
    
    lazy var launchDate: String = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: launch.dateUTC)
    }()
    
    func fetchDetails() async {
        isLoading = true
        error = nil
        
        do {
            self.rocket = try await rocketService.fetch(by: launch.rocket)
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    var videoURL: URL? {
        launch.links?.webcast
    }
    
    var missionPatch: URL? {
        launch.links?.patch?.large ?? launch.links?.patch?.small
    }
} 
