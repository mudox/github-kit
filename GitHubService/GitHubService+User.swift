import Foundation

import Moya
import RxSwift

public extension Service {
 
  // MARK: - User

  typealias CurrentUserResponse = Response<SignedInUser>

  /// Get public as well as private information of current (signed-in) GitHub user.
  ///
  /// - Returns: Single\<CurrentUserResponse\>.
  func currentUser() -> Single<CurrentUserResponse> {
    return provider.request(.currentUser)
      .map(CurrentUserResponse.init)
  }

  typealias UserResponse = Response<User>

  /// Get public information of a GitHub user with given username.
  ///
  /// - Returns: Single\<UserResponse\>.
  func user(name: String) -> Single<UserResponse> {
    return provider.request(.user(name: name))
      .map(UserResponse.init)
  }

}
