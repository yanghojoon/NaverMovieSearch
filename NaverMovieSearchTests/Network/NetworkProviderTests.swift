import RxSwift
import XCTest
@testable import NaverMovieSearch

final class NetworkProviderTests: XCTestCase {
    
    // MARK: - Properties
    var sut: NetworkProvider!
    var disposeBag: DisposeBag!

    // MARK: - Test Setup Methods
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = NetworkProvider()
        disposeBag = DisposeBag()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        sut = nil
        disposeBag = nil
    }
    
    // MARK: - Tests
    func test_fetchData가_한글로_검색_시_제대로_동작하는지_확인() {
        let expectation = XCTestExpectation()
        
        let fetchedData = sut.fetchData(api: NaverMovieAPI(queryTerm: "어벤져스"), decodingType: SearchResult.self)
        _ = fetchedData
            .subscribe(onNext: { searchResult in
                XCTAssertEqual(searchResult.items[0].title, "레고 마블 <b>어벤져스</b>")
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 10)
    }
    
    func test_fetchData가_영어로_검색_시_제대로_동작하는지_확인() {
        let expectation = XCTestExpectation()
        
        let fetchedData = sut.fetchData(api: NaverMovieAPI(queryTerm: "Thor"), decodingType: SearchResult.self)
        _ = fetchedData
            .subscribe(onNext: { searchResult in
                XCTAssertEqual(searchResult.items[0].title, "토르: 러브 앤 썬더")
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 10)
    }

}
