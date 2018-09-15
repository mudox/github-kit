import Foundation

import Moya
import RxSwift

public extension Service {

  typealias RepositoryResponse = PagedResponse<Repository>

  func repository(of username: String, repositoryName: String) -> Single<RepositoryResponse> {
    return provider.request(.repository(username: username, repositoryName: repositoryName))
      .map(RepositoryResponse.init)
  }

  typealias RepositoriesResponse = PagedResponse<[Repository]>

  func myRepositories() -> Single<RepositoriesResponse> {
    return provider.request(.myRepositories)
      .map(RepositoriesResponse.init)
  }

  func repositories(of username: String) -> Single<RepositoriesResponse> {
    return provider.request(.repositories(username: username))
      .map(RepositoriesResponse.init)
  }

  func organizationRepositories(of organizationName: String) -> Single<RepositoriesResponse> {
    return provider.request(.organizationRepositories(organizatinoName: organizationName))
      .map(RepositoriesResponse.init)
  }

}
