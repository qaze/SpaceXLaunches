import XCTest
@testable import SpaceXLaunches

final class LaunchesServiceTests: XCTestCase {
    private var sut: LaunchesServiceImpl!
    private var mockAPIClient: MockAPIClient!
    private var mockCache: MockCacheService!
    
    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
        mockCache = MockCacheService()
        sut = LaunchesServiceImpl(
            apiClient: mockAPIClient,
            cache: mockCache
        )
    }
    
    override func tearDown() {
        sut = nil
        mockAPIClient = nil
        mockCache = nil
        super.tearDown()
    }
    
    func testFetchAll_WhenAPISucceeds_ShouldReturnAndCacheLaunches() async throws {
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
        mockAPIClient.mockResult = expectedLaunches
        let launches = try await sut.fetchAll()
        XCTAssertEqual(launches, expectedLaunches)
        XCTAssertEqual(mockCache.savedObject as? [Launch], expectedLaunches)
        XCTAssertEqual(mockCache.savedPath, .launches)
    }
    
    func testFetchAll_WhenAPIFailsAndCacheAvailable_ShouldReturnCachedData() async throws {
        let expectedLaunches = [
            Launch(
                id: "1",
                name: "Cached Launch",
                dateUTC: Date(),
                rocket: "rocket1",
                details: nil,
                links: nil
            )
        ]
        mockAPIClient.mockError = NSError(domain: "test", code: 1)
        mockCache.mockResult = expectedLaunches
        let launches = try await sut.fetchAll()
        XCTAssertEqual(launches, expectedLaunches)
        XCTAssertEqual(mockCache.loadedPath, .launches)
    }
    
    func testFetchAll_WhenAPIAndCacheFail_ShouldThrowError() async {
        let expectedError = NSError(domain: "test", code: 1)
        mockAPIClient.mockError = expectedError
        mockCache.mockFetchError = expectedError
        mockCache.mockSaveError = expectedError
        do {
            _ = try await sut.fetchAll()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as NSError, expectedError)
        }
    }
    
    func testFetchAll_WhenAPIFailsAndCacheEmpty_ShouldThrowError() async {
        let expectedError = NSError(domain: "test", code: 1)
        mockAPIClient.mockError = expectedError
        mockCache.mockResult = nil
        do {
            _ = try await sut.fetchAll()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as NSError, expectedError)
        }
    }
    
    func testFetchAll_WhenAPISucceedsButCacheFails_ShouldStillReturnData() async throws {
        let expectedLaunches = [
            Launch(
                id: "1",
                name: "Test Launch",
                dateUTC: Date(),
                rocket: "rocket1",
                details: nil,
                links: nil
            )
        ]
        mockAPIClient.mockResult = expectedLaunches
        mockCache.mockFetchError = NSError(domain: "test", code: 1)
        let launches = try await sut.fetchAll()
        XCTAssertEqual(launches, expectedLaunches)
    }
}
