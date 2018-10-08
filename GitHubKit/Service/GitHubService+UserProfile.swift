import Foundation

import Moya
import RxSwift

public extension GitHubService {

  // MARK: - PublicUserProfile

  typealias MyProfileResponse = Response<PrivateUserProfile>

  /// [Get the authenticated user](https://developer.github.com/v3/users/#get-the-authenticated-user)
  ///
  /// - Returns: `Single<CurrentUserResponse>`
  func myProfile
    () -> Single<MyProfileResponse> {
    return provider.rx.request(.myProfile)
      .map(MyProfileResponse.init)
  }

  typealias ProfileResponse = Response<PublicUserProfile>

  /// [Get a single user](https://developer.github.com/v3/users/#get-a-single-user)
  ///
  /// - Returns: `Single<ProfileResponse>`
  func profile(of username: String) -> Single<ProfileResponse> {
    return provider.rx.request(.profile(username: username))
      .map(ProfileResponse.init)
  }

}
