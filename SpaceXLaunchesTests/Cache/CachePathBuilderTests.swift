import XCTest
@testable import SpaceXLaunches

final class CachePathBuilderTests: XCTestCase {
    private var sut: CachePathBuilderImpl!
    private var mockFileManager: MockFileManager!
    private var testCacheURL: URL!
    
    override func setUp() {
        super.setUp()
        mockFileManager = MockFileManager()
        testCacheURL = URL(fileURLWithPath: "/test/cache/directory")
        mockFileManager.mockCachesURL = testCacheURL
        sut = CachePathBuilderImpl(fileManager: mockFileManager)
    }
    
    override func tearDown() {
        sut = nil
        mockFileManager = nil
        testCacheURL = nil
        super.tearDown()
    }
    
    func testMakeFileURL_ForLaunches_ShouldReturnCorrectPath() {
        let url = sut.makeFileURL(for: .launches)
        XCTAssertEqual(
            url,
            testCacheURL.appendingPathComponent("launches_cache.json")
        )
    }
    
    func testMakeFileURL_ForRocket_ShouldIncludeRocketId() {
        let rocketId = "falcon9"
        let url = sut.makeFileURL(for: .rocket(id: rocketId))
        XCTAssertEqual(
            url,
            testCacheURL.appendingPathComponent("rockets_falcon9_cache.json")
        )
    }
    
    func testMakeFileURL_ForRocketWithSpecialCharacters_ShouldHandleThemCorrectly() {
        let rocketId = "falcon-9_heavy#1"
        let url = sut.makeFileURL(for: .rocket(id: rocketId))
        XCTAssertEqual(
            url,
            testCacheURL.appendingPathComponent("rockets_falcon-9_heavy#1_cache.json")
        )
    }
    
    func testMakeFileURL_ShouldUseFirstCacheDirectory() {
        let firstURL = URL(fileURLWithPath: "/first/cache")
        mockFileManager.mockCachesURL = firstURL
        let url = sut.makeFileURL(for: .launches)
        XCTAssertEqual(
            url,
            firstURL.appendingPathComponent("launches_cache.json")
        )
    }
}
