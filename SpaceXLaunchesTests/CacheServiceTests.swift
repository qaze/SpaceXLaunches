import XCTest
@testable import SpaceXLaunches

final class CacheServiceTests: XCTestCase {
    private var sut: CacheServiceImpl!
    private var mockPathBuilder: MockCachePathBuilder!
    private var mockJSONFileCoder: MockJSONFileCoder!
    
    override func setUp() {
        super.setUp()
        mockPathBuilder = MockCachePathBuilder()
        mockJSONFileCoder = MockJSONFileCoder()
        sut = CacheServiceImpl(
            cachePathBuilder: mockPathBuilder,
            jsonFileCoder: mockJSONFileCoder
        )
    }
    
    override func tearDown() {
        sut = nil
        mockPathBuilder = nil
        mockJSONFileCoder = nil
        super.tearDown()
    }
    
    func testSave_WithValidData_ShouldSucceed() throws {
        let testLaunch = Launch(
            id: "1",
            name: "Test Launch",
            dateUTC: Date(),
            rocket: "rocket1",
            details: nil,
            links: nil
        )
        
        XCTAssertNoThrow(try sut.save(testLaunch, to: .launches))
        XCTAssertEqual(mockJSONFileCoder.encodedObject as? Launch, testLaunch)
        XCTAssertEqual(
            mockJSONFileCoder.encodedURL?.lastPathComponent,
            mockPathBuilder.mockURL.lastPathComponent
        )
    }
    
    func testSave_WhenEncodingFails_ShouldThrow() throws {
        let testLaunch = Launch(
            id: "1",
            name: "Test Launch",
            dateUTC: Date(),
            rocket: "rocket1",
            details: nil,
            links: nil
        )
        mockJSONFileCoder.mockError = NSError(domain: "test", code: 1)
        XCTAssertThrowsError(try sut.save(testLaunch, to: .launches))
    }
    
    func testLoad_WithValidData_ShouldReturnDecodedObject() throws {
        let testLaunch = Launch(
            id: "1",
            name: "Test Launch",
            dateUTC: Date(),
            rocket: "rocket1",
            details: nil,
            links: nil
        )
        mockJSONFileCoder.mockResult = testLaunch
        let loaded: Launch = try sut.load(from: .launches)
        XCTAssertEqual(loaded.id, testLaunch.id)
        XCTAssertEqual(loaded.name, testLaunch.name)
        XCTAssertEqual(loaded.rocket, testLaunch.rocket)
        XCTAssertEqual(
            mockJSONFileCoder.decodedURL?.lastPathComponent,
            mockPathBuilder.mockURL.lastPathComponent
        )
    }
    
    func testLoad_WhenDecodingFails_ShouldThrow() {
        mockJSONFileCoder.mockError = DecodingError.dataCorrupted(
            DecodingError.Context(codingPath: [], debugDescription: "Test error")
        )
        XCTAssertThrowsError(try sut.load(from: .launches) as Launch)
    }
}
