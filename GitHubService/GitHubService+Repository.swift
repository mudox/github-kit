import Foundation

import Moya
import RxSwift

public extension Service {

  typealias RepositoryResponse = Response<Repository>

  func repository(of ownerName: String, _ repositoryName: String) -> Single<RepositoryResponse> {
    return provider.request(.repository(ownerName: ownerName, repositoryName: repositoryName))
      .map(RepositoryResponse.init)
  }

  typealias RepositoriesResponse = PagedResponse<[Repository]>

  func myRepositories() -> Single<RepositoriesResponse> {
    return provider.request(.myRepositories)
      .map(RepositoriesResponse.init)
  }

  
  /// [List your repositories](https://developer.github.com/v3/repos/#list-your-repositories)
  ///
  /// - Parameter ownerName: Owner name.
  /// - Returns: `Single<ResositoryResponse>`
  func repositories(of ownerName: String) -> Single<RepositoriesResponse> {
    return provider.request(.repositories(ownerName: ownerName))
      .map(RepositoriesResponse.init)
  }

  func organizationRepositories(of organizationName: String) -> Single<RepositoriesResponse> {
    return provider.request(.organizationRepositories(organizatinoName: organizationName))
      .map(RepositoriesResponse.init)
  }

}
