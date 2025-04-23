import XCTest
@testable import SpaceXLaunches

final class RocketServiceTests: XCTestCase {
    private var sut: RocketServiceImpl!
    private var mockAPIClient: MockAPIClient!
    private var mockCache: MockCacheService!
    
    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
        mockCache = MockCacheService()
        sut = RocketServiceImpl(
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
    
    func testFetch_WhenAPISucceeds_ShouldReturnAndCacheRocket() async throws {
        let rocketId = "falcon9"
        let expectedRocket = Rocket(
            id: rocketId,
            name: "Falcon 9",
            description: "Test description"
        )
        mockAPIClient.mockResult = expectedRocket
        let rocket = try await sut.fetch(by: rocketId)
        XCTAssertEqual(rocket, expectedRocket)
        XCTAssertEqual(mockCache.savedObject as? Rocket, expectedRocket)
        XCTAssertEqual(mockCache.savedPath, .rocket(id: rocketId))
    }
    
    func testFetch_WhenAPIFailsAndCacheAvailable_ShouldReturnCachedData() async throws {
        let rocketId = "falcon9"
        let expectedRocket = Rocket(
            id: rocketId,
            name: "Falcon 9",
            description: "Test description"
        )
        mockAPIClient.mockError = NSError(domain: "test", code: 1)
        mockCache.mockResult = expectedRocket
        let rocket = try await sut.fetch(by: rocketId)
        XCTAssertEqual(rocket, expectedRocket)
        XCTAssertEqual(mockCache.loadedPath, .rocket(id: rocketId))
    }
    
    func testFetch_WhenAPIAndCacheFail_ShouldThrowError() async {
        let rocketId = "falcon9"
        let expectedError = NSError(domain: "test", code: 1)
        mockAPIClient.mockError = expectedError
        mockCache.mockFetchError = expectedError
        mockCache.mockSaveError = expectedError
        do {
            _ = try await sut.fetch(by: rocketId)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as NSError, expectedError)
        }
    }
    
    func testFetch_WhenAPIFailsAndCacheEmpty_ShouldThrowError() async {
        let rocketId = "falcon9"
        let expectedError = NSError(domain: "test", code: 1)
        mockAPIClient.mockError = expectedError
        mockCache.mockResult = nil
        do {
            _ = try await sut.fetch(by: rocketId)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as NSError, expectedError)
        }
    }
    
    func testFetch_WhenAPISucceedsButCacheFails_ShouldStillReturnData() async throws {
        let rocketId = "falcon9"
        let expectedRocket = Rocket(
            id: rocketId,
            name: "Falcon 9",
            description: "Test description"
        )
        mockAPIClient.mockResult = expectedRocket
        mockCache.mockFetchError = NSError(domain: "test", code: 1)
        let rocket = try await sut.fetch(by: rocketId)
        XCTAssertEqual(rocket, expectedRocket)
    }
    
    func testFetch_WithDifferentRocketIds_ShouldUseDifferentCachePaths() async throws {
        let rocketId1 = "falcon9"
        let rocketId2 = "starship"
        let rocket1 = Rocket(
            id: rocketId1,
            name: "Falcon 9",
            description: "Test description"
        )
        let rocket2 = Rocket(
            id: rocketId2,
            name: "Falcon 9",
            description: "Test description"
        )
        mockAPIClient.mockResult = rocket1
        _ = try await sut.fetch(by: rocketId1)
        XCTAssertEqual(mockCache.savedPath, .rocket(id: rocketId1))
        mockAPIClient.mockResult = rocket2
        _ = try await sut.fetch(by: rocketId2)
        XCTAssertEqual(mockCache.savedPath, .rocket(id: rocketId2))
    }
}
