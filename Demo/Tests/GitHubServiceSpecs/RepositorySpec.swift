import XCTest

import Nimble
import Quick

import OHHTTPStubs

import GitHub

import JacKit

class RepositorySpec: QuickSpec { override func spec() {


  beforeEach(Fixtures.setup)
  afterEach(Fixtures.cleanup)
  
  // MARK: repostiory

  it("repository") {
    // Arrange
    let jack = Jack("Service.repository")

    NetworkStubbing.stubIfEnabled(
      name: "repository",
      condition: isMethodGET() && pathMatches("^/repos/[^/]+/[^/]+")
    )

    // Act, Assert
    waitUntil { done in
      _ = Fixtures.gitHubService.repository(of: "github", "explore")
        .subscribe(
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

  // MARK: myRepositories

  it("myRepositories") {
    // Arrange
    let jack = Jack("Service.myRepositories")

    NetworkStubbing.stubIfEnabled(
      name: "myRepositories",
      condition: isMethodGET() && isPath("/user/repos")
    )

    // Act, Assert
    waitUntil { done in
      _ = Fixtures.gitHubService.myRepositories()
        .subscribe(
          onSuccess: { response in
            jack.info("""
            \(Jack.dump(of: response))
            Has \(response.payload.count) repositories
            """)
            done()
          },
          onError: { jack.error(Jack.dump(of: $0)); fatalError() }
        )
    }
  }

  // MARK: repositories

  it("repositories") {
    // Arrange
    let jack = Jack("Service.repositories")

    NetworkStubbing.stubIfEnabled(
      name: "repositories",
      condition: isMethodGET() && pathMatches("^/users/.*/repos")
    )

    // Act, Assert
    waitUntil { done in
      _ = Fixtures.gitHubService.repositories(of: "mudox")
        .subscribe(
          onSuccess: { response in
            jack.info("""
            \(Jack.dump(of: response))
            Has \(response.payload.count) repositories
            """)
            done()
          },
          onError: { jack.error(Jack.dump(of: $0)); fatalError() }
        )
    }
  }

  // MARK: organizationRepositories

  it("organizationRepositories") {
    // Arrange
    let jack = Jack("Service.organizationRepositories")

    NetworkStubbing.stubIfEnabled(
      name: "organizationRepositories",
      condition: isMethodGET() && pathMatches("^/orgs/.*/repos")
    )

    // Act, Assert
    waitUntil { done in
      _ = Fixtures.gitHubService.organizationRepositories(of: "neovim")
        .subscribe(
          onSuccess: { response in
            jack.info("""
            \(Jack.dump(of: response))
            Has \(response.payload.count) repositories
            """)
            done()
          },
          onError: { jack.error(Jack.dump(of: $0)); fatalError() }
        )
    }
  }

  // MARK: repositoryTopics

  it("repositoryTopics") {
    // Arrange
    let jack = Jack("Service.repositoryTopics")

    NetworkStubbing.stubIfEnabled(
      name: "repositoryTopics",
      condition: isMethodGET() && pathMatches("^/users/.*/topics")
    )

    // Act, Assert
    waitUntil { done in
      _ = Fixtures.gitHubService.repositoryTopics(of: "neovim", "neovim")
        .subscribe(
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

  // MARK: repositoryTags

  it("repositoryTags") {
    // Arrange
    let jack = Jack("Service.repositoryTags")

    NetworkStubbing.stubIfEnabled(
      name: "repositoryTags",
      condition: isMethodGET() && pathMatches("^/users/.*/tags")
    )

    // Act, Assert
    waitUntil { done in
      _ = Fixtures.gitHubService.repositoryTags(of: "neovim", "neovim")
        .subscribe(
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

  // MARK: repositoryContributors

  it("repositoryContributors") {
    // Arrange
    let jack = Jack("Service.repositoryContributors")

    NetworkStubbing.stubIfEnabled(
      name: "repositoryContributors",
      condition: isMethodGET() && pathMatches("^/users/.*/contributors")
    )

    // Act, Assert
    waitUntil { done in
      _ = Fixtures.gitHubService.repositoryContributors(of: "neovim", "neovim")
        .subscribe(
          onSuccess: { response in
            jack.info("""
            \(Jack.dump(of: response))
            Has \(response.payload.count) contributors.
            """)
            done()
          },
          onError: { jack.error(Jack.dump(of: $0)); fatalError() }
        )
    }
  }

  // MARK: repositoryLanguages

  it("repositoryLanguages") {
    // Arrange
    let jack = Jack("Service.repositoryLanguages")

    NetworkStubbing.stubIfEnabled(
      name: "repositoryLanguages",
      condition: isMethodGET() && pathMatches("^/users/.*/languages")
    )

    // Act, Assert
    waitUntil { done in
      _ = Fixtures.gitHubService.repositoryLanguages(of: "neovim", "neovim")
        .subscribe(
          onSuccess: { response in
            jack.info("""
            \(Jack.dump(of: response))
            Has \(response.payload.count) languages.
            """)
            done()
          },
          onError: { jack.error(Jack.dump(of: $0)); fatalError() }
        )
    }
  }

} }
