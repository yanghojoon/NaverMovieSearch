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
    // 동일한 메서드를 테스트하는 만큼 API가 잘 동작되는지만 확인이 가능하다. 또한 이런 테스트의 경우 만약 List가 변경되면 테스트가 깨지는 문제가 존재한다.
    func test_fetchData가_한글로_검색_시_제대로_동작하는지_확인() {
        let expectation = XCTestExpectation()
        
        let fetchedData = sut.fetchData(api: NaverMovieAPI(queryTerm: "어벤져스"), decodingType: SearchResult.self)
        _ = fetchedData
            .subscribe(onNext: { searchResult in
                XCTAssertNotEqual(searchResult.items.count, 0)
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
                XCTAssertNotEqual(searchResult.items.count, 0)
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 10)
    }
    
    func test_이상한_검색어를_사용한_경우_값이_나오지_않는지() {
        let expectation = XCTestExpectation()
        
        let fetchedData = sut.fetchData(api: NaverMovieAPI(queryTerm: "ㅁㄴㅇㄹㅁㄴㅇㄹㅁㄴㅇㄹㅁㄴㅇㄹㅎㅂㅈ"), decodingType: SearchResult.self)
        _ = fetchedData
            .subscribe(onNext: { searchResult in
                XCTAssertEqual(searchResult.items.count, 0)
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 10)
    }

}
