import Foundation

import Moya
import RxSwift

public extension GitHubService {

  typealias SearchRepositoryResponse = PagedResponse<SearchPayload>

  /// Search GitHub repositories.
  ///
  /// See Also:
  /// - [Understanding the search syntax](https://help.com/articles/understanding-the-search-syntax/)
  /// - [Searching for repositories](https://help.com/articles/searching-for-repositories/)
  ///
  /// - Parameter query: Query string.
  ///
  /// - Returns: Single\<SearchRepositoryResponse\>.
  func searchRepository(_ query: String) -> Single<SearchRepositoryResponse> {
    return provider.request(.searchRepository(query))
      .map(SearchRepositoryResponse.init)
  }

}
