import XCTest
@testable import SpaceXLaunches

final class URLRequestBuilderTests: XCTestCase {
    private var sut: URLRequestBuilderImpl!
    
    override func setUp() {
        super.setUp()
        sut = URLRequestBuilderImpl()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testMakeUrlRequest_ForLaunches_ShouldReturnCorrectURL() throws {
        let request = try sut.makeUrlRequest(for: .launches)
        XCTAssertEqual(
            request.url?.absoluteString,
            "https://api.spacexdata.com/v4/launches"
        )
    }
    
    func testMakeUrlRequest_ForRocket_ShouldIncludeRocketId() throws {
        let rocketId = "falcon9"
        let request = try sut.makeUrlRequest(for: .rockets(id: rocketId))
        XCTAssertEqual(
            request.url?.absoluteString,
            "https://api.spacexdata.com/v4/rockets/falcon9"
        )
    }
    
    func testMakeUrlRequest_ForRocketWithSpecialCharacters_ShouldHandleThemCorrectly() throws {
        let rocketId = "falcon-9_heavy#1"
        let request = try sut.makeUrlRequest(for: .rockets(id: rocketId))
        XCTAssertEqual(
            request.url?.absoluteString,
            "https://api.spacexdata.com/v4/rockets/falcon-9_heavy#1"
        )
    }
    
    func testMakeUrlRequest_WithInvalidCharactersInRocketId_ShouldStillCreateValidURL() throws {
        let rocketId = "falcon 9 & heavy"
        let request = try sut.makeUrlRequest(for: .rockets(id: rocketId))
        XCTAssertEqual(
            request.url?.absoluteString,
            "https://api.spacexdata.com/v4/rockets/falcon%209%20&%20heavy"
        )
    }
}
