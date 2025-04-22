import XCTest
@testable import SpaceXLaunches

@MainActor
final class LaunchDetailViewModelTests: XCTestCase {
    private var sut: LaunchDetailViewModel!
    private var mockRocketService: MockRocketService!
    private var testLaunch: Launch!
    private var testDate: Date!
    
    override func setUp() {
        super.setUp()
        mockRocketService = MockRocketService()
        let dateFormatter = ISO8601DateFormatter()
        testDate = dateFormatter.date(from: "2023-01-01T12:00:00Z")!
        
        testLaunch = Launch(
            id: "1",
            name: "Test Launch",
            dateUTC: testDate,
            rocket: "rocket1",
            details: "Test launch details",
            links: Launch.Links(
                webcast: URL(string: "https://youtube.com/watch"),
                patch: Launch.Links.Patch(
                    small: URL(string: "https://example.com/small.png"),
                    large: URL(string: "https://example.com/large.png")
                )
            )
        )
        
        sut = LaunchDetailViewModel(
            launch: testLaunch,
            rocketService: mockRocketService
        )
    }
    
    override func tearDown() {
        sut = nil
        mockRocketService = nil
        testLaunch = nil
        testDate = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertNil(sut.rocket)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
    }
    
    func testFetchDetails_WhenSuccessful_ShouldUpdateRocket() async {
        let expectedRocket = Rocket(
            id: "rocket1",
            name: "Test Rocket",
            description: "Test rocket description"
        )
        mockRocketService.mockResult = expectedRocket
        await sut.fetchDetails()
        XCTAssertEqual(sut.rocket, expectedRocket)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
    }
    
    func testFetchDetails_WhenFails_ShouldSetError() async {
        let expectedError = NSError(domain: "test", code: 1)
        mockRocketService.mockError = expectedError
        await sut.fetchDetails()
        XCTAssertNil(sut.rocket)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNotNil(sut.error)
    }
    
    func testFetchDetails_ShouldShowLoadingState() async {
        let expectedRocket = Rocket(
            id: "rocket1",
            name: "Test Rocket",
            description: "Test rocket description"
        )
        var loadingStateObserved = false
        mockRocketService.onFetch = { _ in
            loadingStateObserved = self.sut.isLoading
        }
        mockRocketService.mockResult = expectedRocket
        await sut.fetchDetails()
        XCTAssertTrue(loadingStateObserved)
        XCTAssertFalse(sut.isLoading) // Should be false after completion
    }
    
    func testFetchDetails_WhenRocketNotFound_ShouldShowError() async {
        mockRocketService.mockError = APIError.invalidResponse
        await sut.fetchDetails()
        XCTAssertNil(sut.rocket)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNotNil(sut.error)
    }
    
    func testLaunchDate_ShouldReturnFormattedDate() {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        let expectedDateString = formatter.string(from: testDate)
        XCTAssertEqual(sut.launchDate, expectedDateString)
    }
    
    func testVideoURL_ShouldReturnCorrectURL() {
        XCTAssertEqual(sut.videoURL, URL(string: "https://youtube.com/watch"))
    }
    
    func testMissionPatch_ShouldReturnLargeURL() {
        XCTAssertEqual(sut.missionPatch, URL(string: "https://example.com/large.png"))
    }
    
    func testMissionPatch_WhenOnlySmallAvailable_ShouldReturnSmallURL() {
        let launchWithOnlySmallPatch = Launch(
            id: "1",
            name: "Test Launch",
            dateUTC: testDate,
            rocket: "rocket1",
            details: nil,
            links: Launch.Links(
                webcast: nil,
                patch: Launch.Links.Patch(
                    small: URL(string: "https://example.com/small.png"),
                    large: nil
                )
            )
        )
        
        sut = LaunchDetailViewModel(
            launch: launchWithOnlySmallPatch,
            rocketService: mockRocketService
        )
        XCTAssertEqual(sut.missionPatch, URL(string: "https://example.com/small.png"))
    }
    
    func testMissionPatch_WhenNoPatches_ShouldReturnNil() {
        let launchWithoutPatch = Launch(
            id: "1",
            name: "Test Launch",
            dateUTC: testDate,
            rocket: "rocket1",
            details: nil,
            links: Launch.Links(webcast: nil, patch: nil)
        )
        
        sut = LaunchDetailViewModel(
            launch: launchWithoutPatch,
            rocketService: mockRocketService
        )
        XCTAssertNil(sut.missionPatch)
    }
}
