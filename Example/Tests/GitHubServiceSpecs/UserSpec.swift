import XCTest

import Nimble
import Quick

import OHHTTPStubs

import GitHub

import JacKit

class UserSpec: QuickSpec { override func spec() {

  beforeEach(Fixtures.setup)

  afterEach(Fixtures.cleanup)

  // MARK: myProfile

  it("myProfile") {
    // Arrange
    let jack = Jack("Service.myProfile")

    NetworkStubbing.stubIfEnabled(
      name: "myProfile",
      condition: isMethodGET() && isPath("/user")
    )

    // Act, Assert
    waitUntil { done in
      _ = Fixtures.gitHubService.myProfile().subscribe(
        onSuccess: { response in
          jack.info("""
          \(Jack.dump(of: response))
          \(Jack.dump(of: response.payload))
          """)
          done()
        },
        onError: { jack.error(Jack.dump(of: $0)); fatalError() }
      )
    }
  }

  // MARK: profile

  it("profile") {
    // Arrange
    let jack = Jack("Service.profile")

    NetworkStubbing.stubIfEnabled(
      name: "profile",
      condition: isMethodGET() && pathStartsWith("/users")
    )

    // Act, Assert
    waitUntil { done in
      _ = Fixtures.gitHubService.profile(of: "mudox").subscribe(
        onSuccess: { response in
          jack.info("""
          \(Jack.dump(of: response))
          \(Jack.dump(of: response.payload))
          """)
          done()
        },
        onError: { jack.error(Jack.dump(of: $0)); fatalError() }
      )
    }
  }

  // MARK: - isFollowing

  it("isFollowing") {
    // Arrange
    let jack = Jack("Service.isFollowing")

    NetworkStubbing.stubIfEnabled(
      name: "isFollowing",
      condition: isMethodGET() && pathMatches("^/users/.*/following/")
    )

    // Act, Assert
    waitUntil { done in
      _ = Fixtures.gitHubService.isFollowing(from: "tracy", to: "mudox")
        .subscribe(
          onSuccess: { response in
            jack.info("""
            Is tracy following mudox?
            \(Jack.dump(of: response))
            \(Jack.dump(of: response.payload))
            """)
            done()
          },
          onError: { jack.error(Jack.dump(of: $0)); fatalError() }
        )
    }

    // Act, Assert
    waitUntil { done in
      _ = Fixtures.gitHubService.isFollowing(from: "mudox", to: "kevinzhow")
        .subscribe(
          onSuccess: { response in
            jack.info("""
            Is mudox following kevinzhow?
              \(Jack.dump(of: response))
              \(Jack.dump(of: response.payload))
            """)
            done()
          },
          onError: { jack.error(Jack.dump(of: $0)); fatalError() }
        )
    }
  }

  // MARK: followers

  it("followers") {
    // Arrange
    let jack = Jack("Service.followers")

    NetworkStubbing.stubIfEnabled(
      name: "followers",
      condition: isMethodGET() && pathMatches("^/users/.*/followers")
    )

    // Act, Assert
    waitUntil { done in
      _ = Fixtures.gitHubService.followers(of: "mudox").subscribe(
        onSuccess: { response in
          jack.info("""
          \(Jack.dump(of: response))
          Has \(response.payload.count) followers
          """)
          done()
        },
        onError: { jack.error(Jack.dump(of: $0)); fatalError() }
      )
    }
  }

  // MARK: follow

  it("follow") {
    // Arrange
    let jack = Jack("Service.follow")

    NetworkStubbing.stubIfEnabled(
      name: "follow",
      condition: isMethodPUT() && pathStartsWith("/user/following")
    )

    // Act, Assert
    waitUntil { done in
      let username = "kevinzhow"
      _ = Fixtures.gitHubService.follow(username: username).subscribe(
        onCompleted: {
          jack.info("Followed user \(username)")
          done()
        },
        onError: { jack.error(Jack.dump(of: $0)); fatalError() }
      )
    }
  }

  // MARK: unfollow

  it("unfollow") {
    // Arrange
    let jack = Jack("Service.unfollow")

    NetworkStubbing.stubIfEnabled(
      name: "unfollow",
      condition: isMethodDELETE() && pathStartsWith("/user/following")
    )

    // Act, Assert
    waitUntil { done in
      let username = "kevinzhow"
      _ = Fixtures.gitHubService.unfollow(username: username).subscribe(
        onCompleted: {
          jack.info("Unfollowed user \(username)")
          done()
        },
        onError: { jack.error(Jack.dump(of: $0)); fatalError() }
      )
    }
  }

} }
