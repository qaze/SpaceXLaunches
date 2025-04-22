import XCTest
@testable import SpaceXLaunches

final class APIClientTests: XCTestCase {
    private var sut: APIClientImpl!
    private var mockSession: MockURLSession!
    
    override func setUp() {
        super.setUp()
        mockSession = MockURLSession()
        sut = APIClientImpl(session: mockSession, requestBuilder: MockURLRequestBuilder())
    }
    
    override func tearDown() {
        sut = nil
        mockSession = nil
        super.tearDown()
    }
    
    func testDateDecoding_WithValidISO8601Format_ShouldSucceed() async throws {
        let json = """
        {
            "id": "1",
            "name": "Test Launch",
            "date_utc": "2013-09-29T16:00:00.000Z",
            "rocket": "rocket1"
        }
        """
        mockSession.data = json.data(using: .utf8)!
        mockSession.response = HTTPURLResponse(url: URL(string: "https://test.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let launch: Launch = try await sut.fetch(.launches)
        XCTAssertEqual(launch.id, "1")
        XCTAssertEqual(launch.dateUTC.ISO8601Format(), "2013-09-29T16:00:00Z")
    }
    
    func testDateDecoding_WithInvalidFormat_ShouldThrow() async {
        let json = """
        {
            "id": "1",
            "name": "Test Launch",
            "date_utc": "invalid-date",
            "rocket": "rocket1",
        }
        """
        mockSession.data = json.data(using: .utf8)!
        mockSession.response = HTTPURLResponse(url: URL(string: "https://test.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        do {
            let _: Launch = try await sut.fetch(.launches)
            XCTFail("Expected decoding to fail")
        } catch {
            XCTAssertTrue((error as? APIError) == .decodingFailed)
        }
    }
    
    func testFetch_WithSuccessfulResponse_ShouldReturnDecodedData() async throws {
        let json = """
        {
            "id": "1",
            "name": "Test Launch",
            "date_utc": "2013-09-29T16:00:00.000Z",
            "rocket": "rocket1"
        }
        """
        mockSession.data = json.data(using: .utf8)!
        mockSession.response = HTTPURLResponse(url: URL(string: "https://test.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let launch: Launch = try await sut.fetch(.launches)
        XCTAssertEqual(launch.name, "Test Launch")
        XCTAssertEqual(launch.rocket, "rocket1")
    }
    
    func testFetch_WithErrorStatusCode_ShouldThrowError() async {
        mockSession.data = Data()
        mockSession.response = HTTPURLResponse(url: URL(string: "https://test.com")!, statusCode: 404, httpVersion: nil, headerFields: nil)
        do {
            let _: Launch = try await sut.fetch(.launches)
            XCTFail("Expected error for 404 status code")
        } catch {
            XCTAssertEqual(error as? APIError, .invalidResponse)
        }
    }
    
    func testFetch_WithNetworkError_ShouldThrowError() async {
        mockSession.error = NSError(domain: "network", code: -1)
        do {
            let _: Launch = try await sut.fetch(.launches)
            XCTFail("Expected network error")
        } catch {
            XCTAssertNotNil(error)
        }
    }
}
