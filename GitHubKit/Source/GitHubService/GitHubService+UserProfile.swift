import Foundation

import Moya
import RxSwift

public extension Service {

  // MARK: - PublicUserProfile

  typealias MyProfileResponse = Response<PrivateUserProfile>

  /// Get public as well as private information of current (signed-in) GitHub user.
  ///
  /// - Returns: Single\<CurrentUserResponse\>.
  func myProfile
    () -> Single<MyProfileResponse> {
    return provider.request(.myProfile)
      .map(MyProfileResponse.init)
  }

  typealias ProfileResponse = Response<PublicUserProfile>

  /// Get public information of a GitHub user with given username.
  ///
  /// - Returns: Single\<ProfileResponse\>.
  func profile(of username: String) -> Single<ProfileResponse> {
    return provider.request(.profile(username: username))
      .map(ProfileResponse.init)
  }

}
