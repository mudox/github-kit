import Foundation

import Moya
import RxSwift

public extension Service {
 
  // MARK: - User

  typealias MyProfileResponse = Response<SignedInUser>

  /// Get public as well as private information of current (signed-in) GitHub user.
  ///
  /// - Returns: Single\<CurrentUserResponse\>.
  func myProfile
    () -> Single<MyProfileResponse> {
    return provider.request(.myProfile)
      .map(MyProfileResponse.init)
  }

  typealias UserResponse = Response<User>

  /// Get public information of a GitHub user with given username.
  ///
  /// - Returns: Single\<UserResponse\>.
  func profile(of username: String) -> Single<UserResponse> {
    return provider.request(.profile(username: username))
      .map(UserResponse.init)
  }

}
