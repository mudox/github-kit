import Foundation

import Moya
import RxSwift

public extension GitHubService {

  // MARK: - Listing Repositories

  typealias RepositoryResponse = Response<Repository>

  /// [Get a single repository](https://developer.github.com/v3/repos/#get)
  ///
  /// - Parameters:
  ///   - ownerName: Owner name.
  ///   - repositoryName: Repository name.
  /// - Returns: `Single<Respository>`
  func repository(of ownerName: String, _ repositoryName: String) -> Single<RepositoryResponse> {
    return provider.rx.request(.repository(ownerName: ownerName, repositoryName: repositoryName))
      .map(RepositoryResponse.init)
  }

  typealias RepositoriesResponse = PagedResponse<[Repository]>

  /// [List your repositories](https://developer.github.com/v3/repos/#list-your-repositories)
  ///
  /// - Returns: `Single<RepositoriesResponse>`
  func myRepositories() -> Single<RepositoriesResponse> {
    return provider.rx.request(.myRepositories)
      .map(RepositoriesResponse.init)
  }

  /// [List user repositories](https://developer.github.com/v3/repos/#list-user-repositories)
  ///
  /// - Parameter ownerName: Owner name.
  /// - Returns: `Single<ResositoryResponse>`
  func repositories(of ownerName: String) -> Single<RepositoriesResponse> {
    return provider.rx.request(.repositories(ownerName: ownerName))
      .map(RepositoriesResponse.init)
  }

  /// [List organization repositories](https://developer.github.com/v3/repos/#list-organization-repositories)
  ///
  /// - Parameter organizationName: Organization name.
  /// - Returns: `Single<RepositoriesResponse>`
  func organizationRepositories(of organizationName: String) -> Single<RepositoriesResponse> {
    return provider.rx.request(.organizationRepositories(organizatinoName: organizationName))
      .map(RepositoriesResponse.init)
  }

  // MARK: - Repository Afailiations

  typealias TopicsResponse = Response<Topics>

  /// [List all topics for a repository](https://developer.github.com/v3/repos/#list-all-topics-for-a-repository)
  ///
  /// - Parameters:
  ///   - ownerName: Owner name.
  ///   - repositoryName: Repository name.
  /// - Returns: `Single<TopicsResponse>`
  func repositoryTopics(of ownerName: String, _ repositoryName: String) -> Single<TopicsResponse> {
    return provider.rx.request(.topics(ownerName: ownerName, repositoryName: repositoryName))
      .map(TopicsResponse.init)
  }

  typealias TagsResponse = PagedResponse<[Tag]>

  /// [List all tags for a repository](https://developer.github.com/v3/repos/#list-tags)
  ///
  /// - Parameters:
  ///   - ownerName: Owner name.
  ///   - repositoryName: Repository name.
  /// - Returns: `Single<TopicsResponse>`
  func repositoryTags(of ownerName: String, _ repositoryName: String) -> Single<TagsResponse> {
    return provider.rx.request(.tags(ownerName: ownerName, repositoryName: repositoryName))
      .map(TagsResponse.init)
  }

  typealias ContributorsResponse = PagedResponse<[Contributor]>

  /// [List all contributors for a repository](https://developer.github.com/v3/repos/#list-contributors)
  ///
  /// - Parameters:
  ///   - ownerName: Owner name.
  ///   - repositoryName: Repository name.
  /// - Returns: `Single<TopicsResponse>`
  func repositoryContributors(of ownerName: String, _ repositoryName: String) -> Single<ContributorsResponse> {
    return provider.rx.request(.contributors(ownerName: ownerName, repositoryName: repositoryName))
      .map(ContributorsResponse.init)
  }

  typealias LanguagesResponse = Response<[String: Int]>

  /// [List all languages for a repository](https://developer.github.com/v3/repos/#list-languages)
  ///
  /// - Parameters:
  ///   - ownerName: Owner name.
  ///   - repositoryName: Repository name.
  /// - Returns: `Single<TopicsResponse>`
  func repositoryLanguages(of ownerName: String, _ repositoryName: String) -> Single<LanguagesResponse> {
    return provider.rx.request(.languages(ownerName: ownerName, repositoryName: repositoryName))
      .map(LanguagesResponse.init)
  }

}
