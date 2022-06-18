import RxSwift
import XCTest
@testable import NaverMovieSearch

final class MockNetworkProviderTests: XCTestCase {
    
    // MARK: - Properties
    let mockURLSession: URLSessionProtocol = MockURLSession()
    var sut: NetworkProvider!
    var disposeBag: DisposeBag!
    
    // MARK: - Test Setup Methods
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = NetworkProvider(session: mockURLSession)
        disposeBag = DisposeBag()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        sut = nil
        disposeBag = nil
    }
    
    // MARK: - Tests
    func test_fetchData가_제대로_작동하는지() {
        let expectation = XCTestExpectation()
        
        let fetchedData = sut.fetchData(
            api: NaverMovieAPI(queryTerm: "주마등<b>주식</b>회사"),
            decodingType: SearchResult.self
        )
        _ = fetchedData
            .subscribe(onNext: { searchResult in
                XCTAssertEqual(searchResult.items[0].title, "주마등<b>주식</b>회사")
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 10)
    }

}
