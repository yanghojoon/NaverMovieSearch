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
    // 동일한 메서드를 테스트하는 만큼 API가 잘 동작되는지만 확인이 가능하다. 테스트 케이스를 추가하는 것이 어떨까?
    func test_fetchData가_한글로_검색_시_제대로_동작하는지_확인() {
        let expectation = XCTestExpectation()
        
        let fetchedData = sut.fetchData(api: NaverMovieAPI(queryTerm: "어벤져스"), decodingType: SearchResult.self)
        _ = fetchedData
            .subscribe(onNext: { searchResult in
                XCTAssertEqual(searchResult.items[0].title, "레고 마블 <b>어벤져스</b>") // 테스트 결과가 달라질 수 있다.
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
