# 🔍 네이버 영화검색
[Naver의 OpenAPI](https://developers.naver.com/docs/serviceapi/search/movie/movie.md#%EC%98%81%ED%99%94)를 활용해 영화를 검색하고 즐겨찾기를 할 수 있는 앱입니다 

## 🗂 파일 디렉토리 구조
```
├── NaverMovieSearch
│   ├── App
│   ├── Presentation
│   │   ├── Search
│   │   │   ├── View
│   │   │   └── ViewModel
│   │   ├── Detail
│   │   │   ├── View
│   │   │   └── ViewModel
│   │   └── Favorites
│   │       ├── View
│   │       └── ViewModel
│   ├── Model
│   ├── Network
│   ├── Protocol
│   ├── Extension
│   ├── Utility
│   └── Resources
└── NaverMovieSearchTests
    └──Network
        └── Mock
```

## ⌨️ 사용한 오픈소스 / DeploymentTarget / 의존성 관리 도구
### 사용한 오픈소스 
- `RxSwift` : 비동기 처리를 반환 값으로 처리하여 Reactive Programming을 할 수 있도록 사용
- `RxDataSource` : DataSource에 값을 추가하여 새로운 페이지를 로드할 수 있도록 구현하기 위해 사용

### iOS Deployment Target
- `iOS 13.0`으로 설정: 현재 대부분의 상용 앱(카카오톡, 원티드, 자소설닷컴, 네이버 등)이 `iOS 13.0` 이상을 최소 타겟으로 잡고 있어 `iOS 13.0`으로 설정

### 의존성 관리 도구 
- `SPM` : 애플이 제공하는 FirstParty이기도 하고, CocoaPods와 달리 프로젝트를 확인하는 사람이 따로 install하는 번거로움도 없어 사용

## 1️⃣ [영화 검색 및 결과 목록 화면을 구현](https://github.com/yanghojoon/NaverMovieSearch/pull/1)
### 기능 요약
[네이버 영화 API](https://developers.naver.com/docs/serviceapi/search/movie/movie.md#%EC%98%81%ED%99%94)를 통해 검색어에 해당하는 영화 목록을 불러옵니다. 
각 Cell에 있는 별표를 누르면 즐겨찾기 목록에 등록되며, 다른 곳을 검색하고 오더라도 별표는 유지됩니다.  

### 작업 내용
#### 1. 네이버 API 등록 및 네트워킹 코드 추상화
네이버 API의 경우 Bundle ID와 함께 앱을 등록해야 API를 사용할 수 있었기에 등록을 진행했습니다. 등록과 함께 나오는 ID와 Secret의 경우 URLRequest를 해줄 때 Header로 추가를 해줘야 했습니다. 

따라서 URLRequest의 Extension에서 init을 구현하여, 여기서 header를 설정해줄 수 있도록 구현했습니다. 
```swift
extension URLRequest {
    init?(api: APIProtocol) {
        let clientID = "{ID를 넣었습니다}"
        let clientSecret = "{Secret 값을 넣었습니다}"
   
        guard let url = api.url else {
            return nil
        }
        
        self.init(url: url)
        self.httpMethod = "\(api.method)"
        self.setValue(clientID, forHTTPHeaderField: "X-Naver-Client-Id")
        self.setValue(clientSecret, forHTTPHeaderField: "X-Naver-Client-Secret")
    }
}
```

확장성을 고려해 요청할 API를 `APIProtocol`로 추상화해서 만약 API가 추가되더라도 프로토콜만 채택하면 되도록 했습니다. 다만 `HttpMethod`의 경우 아직 Get만 사용하면 되기 때문에 case를 `get`만 뒀습니다.

URLSession의 경우 `MockURLSession` 추가를 위해 이를 한 단계 추상화하고, URLSession이 이를 채택하도록 했습니다. 

#### 2. CollectionView의 Separator 구현
TableView와 달리 CollectionView는 TableView같은 `Separator`가 자동으로 구현이 되지 않습니다. 
따라서 이를 어떻게 구현할 지 고민하다가 `backgroundColor`를 `systemGray6`으로 하고 CollectionView의 item 간 `contentInsets`을 상하로 줘서, background가 Separator처럼 보일 수 있도록 했습니다. 

#### 3. 별 표시를 유지하는 로직을 고민했습니다. 
사용자가 즐겨찾기를 추가하는 경우 다른 검색어로 검색을 하고 오더라도 별 표시가 유지되는 것이 적합하다고 판단했습니다. 
기존에는 'Cell이 본인이 선택되었는지 들고 있으면 되지 않을까' 생각했으나 Cell이 재사용되면서 별 표시가 변경되는 문제가 있었습니다. 따라서 Cell이 재사용될 때마다 해당 영화가 즐겨찾기로 등록되었는지 알 수 있는 방법이 필요했습니다. 

따라서 이를 위해 `CellItem`이라는 class를 추가했습니다. 인스턴스를 힙 영역에 두고 즐겨찾기에 등록되거나 삭제될 때 이를 변경해줘야 했기에 구조체보다는 클래스가 적합하다고 판단했습니다. 
또한 즐겨찾기 목록에서 해당 영화가 포함되어 있는지, index가 뭔지 알 수 있어야 했기에 Equatable 프로토콜을 채택했습니다. 

<로직 순서>
1. `Cell`에서 star를 누르면 색을 변경하고 Item의 `isSelected` 프로퍼티 변경
2. delegate를 통해 `MovieSearchViewController`가 `MoviewSearchViewModel`로 Movie 타입과 선택됐는지에 대한 bool 타입을 전달
3. `MoviewSearchViewModel`에 배열로 즐겨찾기 목록을 저장하고 추가, 삭제를 Bool 타입을 통해 처리
4. 이후 다시 검색을 하게 되는 경우, 저장된 배열에 해당 영화가 있는지 확인 후 있다면 `isSelected`를 true로 해서 `CellItem` 전달

#### 4. UX 향상을 위한 로직 추가
- TextField의 placeholder 추가 
- 검색하면 CollectionView의 최상단으로 이동하도록 구현
- Search 버튼을 누르면 키보드가 dismiss되도록 구현
- return 버튼이 아닌 search 버튼이 나오도록 TextField의 `returnKeyType` 변경
- 화면 크기에 맞게 Cell 높이 조정 (화면 크기가 750보다 작은 경우와 큰 경우로 분기)

### 테스트 방법
네트워크 통신의 경우 크게 2가지로 테스트가 가능합니다. 
#### 1. MockURLSession을 활용한 테스트 
MockURLSession을 활용해 테스트를 할 경우 다음과 같은 장점이 있다고 판단했습니다. 
- 네트워크 환경에 관계없이 테스트가 가능하다. 
- 추가로 Post / Put / Patch / Delete 같은 HttpMethod를 테스트하는 경우 서버에 영향을 주지 않고 테스트가 가능하다. 

따라서 네트워크를 활용한 테스트 이외에 MockURLSession을 활용한 테스트를 추가했습니다. 
초기화를 할 때 `isRequestSuccess`를 `false`로 하지 않는 한 항상 성공만 나올 수 있도록 했습니다. 
성공한 경우 `MockSearchResult` 데이터를 항상 반환하도록 했고, 실패하는 경우 데이터는 `nil`이 나옵니다. 

`NetworkProvider`에서 dataTask로 나온 `URLSessionDataTask`에 `resume`과 `cancel`을 사용하기 때문에 `MockURLSessionDataTask`에서 `resume`과 `cancel`을 아무 동작도 하지 않도록 재정의했습니다. 

#### 2. 실제 네트워킹 테스트
물론 MockURLSession을 통해 네트워크 로직이 정상적으로 동작하는지 검증이 가능하나 실제 API가 제공하는 데이터를 확인하기 위해 네트워킹 테스트를 별도로 진행했습니다. 

테스트의 경우 한글과 영어 검색어 모두 테스트를 진행했습니다. 비동기로 진행되는 테스트인 만큼 10초의 대기 시간을 두고 해당 시간 내에 조건을 충족하는지 확인했습니다.

#### +. JSON Parsing 테스트
추가적으로 JSON 데이터가 모델 타입으로 Parsing되는지 파악하기 위해 `JSONParserTests`를 구현했습니다. 
네이버 영화 API에 등록되어 있는 예제를 바탕으로 `MockSearchResult`를 만들었고, 이를 모델 타입을 통해 정상적으로 Parsing되는지 확인합니다. 

### 스크린샷
<img src="https://user-images.githubusercontent.com/90880660/173857699-68eb33f4-6ab1-4d5d-a98e-01e646adf8bb.gif" width=250>

## 2️⃣ [영화 내용 상세 화면을 보여줌](https://github.com/yanghojoon/NaverMovieSearch/pull/2)
### 기능 요약
셀을 선택한 경우 해당 셀에 해당하는 상세화면을 보여줍니다. 
기존 셀에 보였던 간단한 설명과 함께 WebView를 보여줍니다. 

### 작업 내용
#### 1. 즐겨찾기를 추가할 수 있는 로직에 대해 고민했습니다. 
DetailView에서도 즐겨찾기를 추가, 삭제할 수 있어야 했습니다. 그래서 기존 Delegate 패턴을 다시 활용하는 방법을 선택했습니다. 
일단 `MovieCell`의 Delegate를 `MovieDetailViewController`가 하도록 하고, 이를 또 `MovieSearchViewController`가 처리해줄 수 있도록 했습니다.
이때 DetailView에서의 Cell의 IndexPath와 ListView에서의 Cell의 Index가 달랐고, 기존 ListView의 IndexPath가 필요했습니다.
```swift
// MovieDetailViewController Delegate
func starButtonDidTap(at indexPath: IndexPath, isSelected: Bool) {
    guard let selectedCell = listCollectionView.cellForItem(at: indexPath) as? MovieCell else { return }
    
    favoriteMovie.onNext((selectedCell.makeMovieItem(), isSelected))
}
```
따라서 `DetailCoordinator`를 통해 Detail 화면으로 전환하는 경우 Cell의 Item과 IndexPath를 `Zip`을 통해 묶어서 보낼 수 있도록 했습니다. 

이를 통해 DetailView에서 즐겨찾기 버튼을 누르더라도 즐겨찾기 목록에 추가 / 삭제가 가능할 수 있도록 했습니다. 

또한 DetailView에서 `Back Button`을 누르는 경우 collectionView가 refresh되어야 했기에 `viewWillAppear`에 `listCollectionView`를 `reloadData()`해줬습니다. 


#### 2. `MovieDetailViewController`가 종료되면 메모리에서 DetailCoordinator도 내려가도록 했습니다. 
화면을 `Back Button`을 통해 `Pop`하더라도 기존 `SearchCoordinator`의 `childCoordinators` 배열에 append가 되어 있어 `DetailCoordinator`가 메모리에서 내려오지 않는 문제가 있었습니다. 

따라서 ViewModel에서 `BackButton`을 탭했을 때 `DetailCoordinator`의 `finish` 메서드를 호출하여 기존 배열에서 제거해주려고 했으나 
`navigationItem.backBarButtonItem`이 계속 nil이 나오는 문제점이 있었습니다. 이를 해결하기 위해 기존 `MovieSearchViewController`에서 `bactBarButtonItem`을 넘겨줬지만 `BackButton`을 탭했는지 확인할 수 없었습니다. 

`BackButton`을 누르게 되면 `popViewController`가 되면서 기존에 떠있던 ViewController이 deinit이 되기 때문에 여기서 `DetailCoordinator`의 `finish` 메서드를 호출하도록 방법을 변경했습니다. 

#### 3. WebView를 통해 Link에 해당하는 내용을 보여줬습니다. 
기존 받아오는 Data에 해당 영화에 대한 Link도 받을 수 있었습니다. 따라서 `WKWebView`를 사용해 이를 보여줄 수 있도록 했습니다. 
이미 iOS 12.0에서 Deprecated된 `UIWebView`의 경우 성능상(렌더링 가능 수가 2배 이상 차이)으로도 떨어지고 이미 사용할 수 없어 고려 대상에서 제외했고, `SFSafariViewController`의 경우 아예 사파리를 실행해서 보여주기 때문에 `WKWebView`이 가장 적합하다고 판단했습니다. 

그래서 Link를 URLRequest로 변경하여 WKWebView의 load 메서드를 활용하려 했으나 다음과 같은 에러가 발생했습니다. 

>WebPageProxy::didFailProvisionalLoadForFrame: frameID = 3, domain = NSURLErrorDomain, code = -1022

따라서 Info.plist에서 `App Transport Security Settings` > `Allow Arbitary Loads`를 `YES`로 추가해주었습니다. 

### 스크린샷
<img src="https://user-images.githubusercontent.com/90880660/173991864-e9839a70-3ce3-4236-b5c7-266a5417d9b1.gif" width=250>

## 3️⃣ [즐겨찾기 버튼을 누르면 지금까지 즐겨찾기에 등록한 목록이 보임](https://github.com/yanghojoon/NaverMovieSearch/pull/3)
### 기능 요약
즐겨찾기 버튼을 누르는 경우 지금까지 즐겨찾기로 등록한 목록이 보입니다. 여기서 Cell을 선택했을 때에도 상세 화면을 확인할 수 있습니다. 

**<추가로 구현한 내용>**
- 스크롤을 내렸을 때 해당 검색어에 대한 추가적인 Fetch가 가능한 경우 네트워킹을 통해 추가 목록을 불러옵니다. 
- ActivityIndicatorView를 통해 현재 데이터를 불러오고 있음을 보여줍니다. 
- 검색어에 대한 결과가 없는 경우 Alert를 통해 다시 검색할 수 있도록 합니다. 

### 작업 내용
#### 1. 즐겨찾기 목록을 보여줄 수 있는 로직에 대해 고민했습니다. 
기존 즐겨찾기 목록은 `MovieSearchViewModel`에 배열로 값을 가지고 있었던 만큼 해당 데이터를 `FavoritesCoordinator`로 전달할 수 있도록 했습니다. 
이를 `FavoritesViewModel`로 전달받아 View에서 띄울 수 있도록 했습니다. 즐겨찾기 목록의 경우도 기존 리스트와 동일하게 셀을 선택하는 경우 상세화면을 확인할 수 있도록 했습니다. 

상세화면의 경우 기존 생성해놓았던 DetailCoordinator를 재사용하여 띄울 수 있도록 했습니다.

#### 2. 스크롤을 내렸을 때 추가로 load할 수 있는 Item이 있다면 추가로 CollectionView에 추가할 수 있도록 했습니다. 
항상 한정된 양의 컨텐츠를 보여주는 것보다 추가적인 컨텐츠가 있다면 이를 추가로 보여주는 것이 맞다고 판단했습니다. 
따라서 CollectionView의 Delegate를 활용해 CollectionView가 스크롤될 때마다 IndexPath를 `MovieSearchViewModel`로 전달받았고, IndexPath의 Row가 현재 검색된 양보다 3만큼 작은 경우 추가로 데이터를 불러옵니다. 
(ex. 현재 불러온 컨텐츠가 40개라면 Row가 37일 때 새로운 데이터를 불러오게 됩니다. 이렇게 구현한 이유는 CollectionView가 끝까지 스크롤되기 전에 데이터를 빠르게 불러오기 위함입니다.)

DataSource에 값을 추가해주기 위해 `RxDataSource` 라이브러리를 추가로 사용했습니다. 이를 사용하는 경우 DataSource를 통해 CollectionView에 바인딩을 한 후 DataSource에 값만 추가해줘도 CollectionView의 Cell이 추가됐기 때문에 사용하는 것이 적합하다고 판단했습니다.

`MovieSearchViewModel`의 데이터는 초기값을 가지고 있는 것이 적합하다고 판단해 `BehaviorSubject`를 사용했습니다. 

#### 3. ActivityIndicatorView를 통해 앱이 로딩 중임을 보여줍니다. 
사용자가 앱이 로딩 중인지 알 수 있도록 `ActivityIndicatorView`를 활용했습니다. 
`TextFieldDelegate`의 `textFieldShouldReturn` 함수에서 `ActivityIndicatorView`를 `startAnimating`하고, 검색이 완료되는 경우 이를 숨겨야 했기에 기존 `MovieSearchViewModel`의 `configureMovieList`에서 데이터를 불러오면 `ActivityIndicatorView`를 `stopAnimating`했습니다. 

로딩 서클을 멈추는 것을 ViewModel에서 처리해주기 위해 Delegation 패턴을 활용했습니다. 

#### 4. 검색어에 대한 결과가 없는 경우 Alert를 통해 결과가 없음을 알 수 있도록 합니다. 
결과가 없는 경우 단순히 빈 화면을 보여주는 것보단 결과값이 없다는 것을 명확하게 전달하는 것이 맞다고 판단했습니다. 
따라서 Label을 띄울지, Alert를 띄울지 고민하다 사용자가 직접 확인 버튼을 누를 수 있는 Alert가 전달이 더 명확히 된다고 판단하여 Alert를 사용했습니다. 

Alert의 경우 아래 메서드에서 searchResult.items의 count가 0일 때 Delegation 패턴을 띄울 수 있도록 했습니다. 
```swift
 private func configureMovieList(with inputObserver: Observable<String>) -> Observable<[MovieSection]> {
    inputObserver
        .withUnretained(self)
        .flatMap { (self, searchKeyword) -> Observable<[MovieSection]> in
            self.searchStart = 1
            
            let sections = self.fetchMovieData(from: searchKeyword, start: self.searchStart)
                .flatMap { searchResult -> Observable<[MovieSection]> in
                    if searchResult.items.count == .zero {
                        DispatchQueue.main.async {
                            self.delegate.showNoResultAlert()
                        }
                    } else {
                        let cellItems = self.createCellItem(from: searchResult.items)
                        let sections = [
                            MovieSection(header: "영화목록", items: cellItems)
                        ]
                        self.collectionViewDataSources.onNext(sections)
                    }
                    
                    DispatchQueue.main.async {
                        self.delegate.stopLoadingActivityIndicator()
                    }
                
                return self.collectionViewDataSources.asObservable()
            }
            
            return sections
        }
}
```
Alert를 띄우는 것도 UI와 관련된 Action인 만큼 Main Thread에서 동작할 수 있도록 했습니다. 

### 스크린샷
|즐겨찾기|무한 스크롤|검색결과 없음|
|---|---|---|
|<img src="https://user-images.githubusercontent.com/90880660/174446589-b25147da-4d33-42b0-8e72-803b7ee3af67.gif" width=250>|<img src="https://user-images.githubusercontent.com/90880660/174446760-bd6023a2-ed42-4dfe-a127-647293df9991.gif" width=250>|<img src="https://user-images.githubusercontent.com/90880660/174446833-b58fba84-4922-48ed-a68b-2a1884d4e798.gif" width=250>|

## 4️⃣ 리팩토링 (고려하지 못했던 부분 & 수정할 부분)
### 1. ClientID와 Secret을 코드에 노출시켜놨다. 
ClientID와 Secret의 경우 외부에 탈취된다면 위험할 수 있다. 물론 현재는 단순히 네이버 영화 API를 사용하는 것이기 때문에 큰 문제가 없지만, 만약 실제 회사에서 사용하는 ClientID와 Secret이 노출되었다면? 이렇게 되면 회사에 손실이 있을 수 있다. 

따라서 이를 숨기는 것이 좋다. 
- 가장 간단한 방법은 단순히 Repo를 private으로 하는 것이다. 그럼 회사 외부 사람들의 경우 코드를 확인할 수 없기 때문에 안전하다. 
- 다른 방법은 해당 부분을 표시해두고 필요할 경우 ID와 Secret을 따로 보내는 것이다. 

생각을 못했는데 실무에선 중요한 부분인 만큼 잘 챙겨야 할 것 같다. 
이 부분은 해당 부분을 표시해두고 ID와 Secret을 따로 저장하는 방식으로 해결했다. 

### 2. 네트워킹 테스트의 역할
MockURLSession을 활용한 테스트와 거의 동일하게 테스트를 진행하여 `NetworkProviderTests`가 단순히 API가 잘 작동하고 있는지 테스트하는 다소 의미없는 테스트가 됐다. 
따라서 해당 테스트 외 다른 테스트 추가가 필요하다. 

<새롭게 추가 / 수정한 테스트>
- 기존 Test의 경우 검색 결과가 바뀌면 테스트가 깨지는 문제가 발생하여, 검색 결과가 있는지 없는지로 테스트 변경
- 이상한 검색어로 검색을 한 경우 검색결과가 없는지 테스트 추가
- ID와 Secret이 잘못된 경우 통과하는 테스트를 둬서 ID와 Secret이 문제인지 확인할 수 있도록 함

### 3. 즐겨찾기 추가 및 제거 방법 
기존에는 메모리에 즐겨찾기 목록을 저장해놓고 사용하는 방식을 사용했다. 하지만 이렇게 할 경우 Delegate 패턴을 활용해 기존 배열이 저장되어 있는 곳에 일을 시켜 즐겨찾기 목록을 추가 / 삭제해야 했다. 
이는 아예 Realm이나 CoreData를 활용해 LocalDB에 저장하는 방식으로 즐겨찾기 추가 및 삭제를 구현할 수 있을 것 같다. 

### 4. BehaviorSubject 대신 drive를 사용할 수 있지 않을까?

