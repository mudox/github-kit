import Foundation

import Moya
import RxSwift

public extension GitHubService {

  typealias ReferenceResponse = Response<Reference>

  func reference(
    of ownerName: String, _ repositoryName: String,
    withPath path: String
  )
    -> Single<ReferenceResponse> {
    return provider.rx.request(.reference(ownerName: ownerName, repositoryName: repositoryName, path: path))
      .map(ReferenceResponse.init)
  }

  typealias CommitResponse = Response<Commit>

  func commit(
    of ownerName: String, _ repositoryName: String,
    withSHA sha: String
  )
    -> Single<CommitResponse> {

    return provider.rx.request(.commit(ownerName: ownerName, repositoryName: repositoryName, sha: sha))
      .map(CommitResponse.init)
  }

  typealias TreeResponse = Response<Tree>

  func tree(
    of ownerName: String, _ repositoryName: String,
    withSHA sha: String
  )
    -> Single<TreeResponse> {
    return provider.rx.request(.tree(ownerName: ownerName, repositoryName: repositoryName, sha: sha))
      .map(TreeResponse.init)
  }

  typealias BlobRawResponse = RawDataResponse

  /// [Get a blob](https://developer.github.com/v3/git/blobs/#get-a-blob)
  ///
  /// - Parameters:
  ///   - ownerName: Owner username of the repository from which to get the blob.
  ///   - repositoryName: The repository name.
  ///   - sha: SHA-1 value of the blob object.
  /// - Returns: `Single<BlobRawResponse>`
  func blob(
    of ownerName: String, _ repositoryName: String,
    withSHA sha: String
  )
    -> Single<BlobRawResponse> {
    return provider.rx.request(.blob(ownerName: ownerName, repositoryName: repositoryName, sha: sha))
      .map(BlobRawResponse.init)
  }

  // swiftlint:enable opening_brace

} // struct Service
