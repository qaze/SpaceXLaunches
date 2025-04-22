import XCTest
@testable import SpaceXLaunches

@MainActor
final class LaunchListViewModelTests: XCTestCase {
    private var sut: LaunchListViewModel!
    private var mockLaunchService: MockLaunchService!
    
    override func setUp() {
        super.setUp()
        mockLaunchService = MockLaunchService()
        sut = LaunchListViewModel(launchService: mockLaunchService)
    }
    
    override func tearDown() {
        sut = nil
        mockLaunchService = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertTrue(sut.launches.isEmpty)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
    }
    
    func testFetchLaunches_WhenSuccessful_ShouldUpdateLaunches() async {
        let expectedLaunches = [
            Launch(
                id: "1",
                name: "Test Launch 1",
                dateUTC: Date(),
                rocket: "rocket1",
                details: nil,
                links: nil
            ),
            Launch(
                id: "2",
                name: "Test Launch 2",
                dateUTC: Date(),
                rocket: "rocket2",
                details: nil,
                links: nil
            )
        ]
        mockLaunchService.mockResult = expectedLaunches

        await sut.fetchLaunches()
        
        XCTAssertEqual(sut.launches, expectedLaunches)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
    }
    
    func testFetchLaunches_WhenFails_ShouldSetError() async {
        let expectedError = NSError(domain: "test", code: 1)
        mockLaunchService.mockError = expectedError
        
        await sut.fetchLaunches()
        
        XCTAssertTrue(sut.launches.isEmpty)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNotNil(sut.error)
    }
    
    func testFetchLaunches_ShouldShowLoadingState() async {
        var loadingStateObserved = false
        mockLaunchService.onFetch = {
            loadingStateObserved = self.sut.isLoading
        }
        await sut.fetchLaunches()
        XCTAssertTrue(loadingStateObserved)
        XCTAssertFalse(sut.isLoading) // Should be false after completion
    }
    
    func testFetchLaunches_WhenCalledMultipleTimes_ShouldUpdateLaunches() async {
        let firstLaunches = [
            Launch(
                id: "1",
                name: "Test Launch 1",
                dateUTC: Date(),
                rocket: "rocket1",
                details: nil,
                links: nil
            )
        ]
        
        let secondLaunches = [
            Launch(
                id: "2",
                name: "Test Launch 2",
                dateUTC: Date(),
                rocket: "rocket2",
                details: nil,
                links: nil
            )
        ]
        mockLaunchService.mockResult = firstLaunches
        await sut.fetchLaunches()
        XCTAssertEqual(sut.launches, firstLaunches)
        mockLaunchService.mockResult = secondLaunches
        await sut.fetchLaunches()
        XCTAssertEqual(sut.launches, secondLaunches)
    }
}
