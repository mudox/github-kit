import Foundation

import Moya
import RxSwift

public extension Service {

  typealias RepositoryResponse = Response<Repository>

  /// [Get a single repository](https://developer.github.com/v3/repos/#get)
  ///
  /// - Parameters:
  ///   - ownerName: Owner name.
  ///   - repositoryName: Repository name.
  /// - Returns: `Single<Respository>`
  func repository(of ownerName: String, _ repositoryName: String) -> Single<RepositoryResponse> {
    return provider.request(.repository(ownerName: ownerName, repositoryName: repositoryName))
      .map(RepositoryResponse.init)
  }

  typealias RepositoriesResponse = PagedResponse<[Repository]>

  /// [List your repositories](https://developer.github.com/v3/repos/#list-your-repositories)
  ///
  /// - Returns: `Single<RepositoriesResponse>`
  func myRepositories() -> Single<RepositoriesResponse> {
    return provider.request(.myRepositories)
      .map(RepositoriesResponse.init)
  }

  /// [List user repositories](https://developer.github.com/v3/repos/#list-user-repositories)
  ///
  /// - Parameter ownerName: Owner name.
  /// - Returns: `Single<ResositoryResponse>`
  func repositories(of ownerName: String) -> Single<RepositoriesResponse> {
    return provider.request(.repositories(ownerName: ownerName))
      .map(RepositoriesResponse.init)
  }

  /// [List organization repositories](https://developer.github.com/v3/repos/#list-organization-repositories)
  ///
  /// - Parameter organizationName: Organization name.
  /// - Returns: `Single<RepositoriesResponse>`
  func organizationRepositories(of organizationName: String) -> Single<RepositoriesResponse> {
    return provider.request(.organizationRepositories(organizatinoName: organizationName))
      .map(RepositoriesResponse.init)
  }
  
  typealias TopicsResponse = Response<Topics>
  
  
  /// [List all topics for a repository](https://developer.github.com/v3/repos/#list-all-topics-for-a-repository)
  ///
  /// - Parameters:
  ///   - ownerName: Owner name.
  ///   - repositoryName: Repository name.
  /// - Returns: `Single<TopicsResponse>`
  func topics(of ownerName: String, repositoryName: String) -> Single<TopicsResponse> {
    return provider.request(.topics(ownerName: ownerName, repositoryName: repositoryName))
      .map(TopicsResponse.init)
  }

}
