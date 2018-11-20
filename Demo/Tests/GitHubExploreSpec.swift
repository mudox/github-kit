import XCTest

import Nimble
import Quick

import OHHTTPStubs

@testable import GitHub

import JacKit

class GitHubExploreSpec: QuickSpec { override func spec() {

  beforeEach(Fixtures.setup)
  afterEach(Fixtures.cleanup)

  // MARK: synchronize

  it("synchronize") {
    // Arrange
    let jack = Jack("Test.GitHub.Explore.synchronize")

    // Act, Assert
    waitUntil { done in
      _ = GitHub.Explore.synchronize
        .subscribe(
          onCompleted: {
            jack.descendant("onCompleted").info("downloading completed successfully")
            done()
          },
          onError: { error in
            jack.descendant("onError").error(dump(of: error))
            fatalError()
          }
        )
    }
  }

  // MARK: curatedTopics

  it("curatedTopics") {
    // Arrange
    let jack = Jack("Test.GitHub.Explore.curatedTopics")

    // Act, Assert
    waitUntil { done in
      _ = GitHub.Explore.curatedTopics()
        .subscribe(
          onSuccess: { topics in
            jack.descendant("onSuccess").info("Found \(topics.count) curated topics")
            done()
          },
          onError: { error in
            jack.descendant("onError").error(dump(of: error))
            fatalError()
          }
        )
    }
  }

  // MARK: collections

  it("collections") {
    // Arrange
    let jack = Jack("Test.GitHub.Explore.collections")

    // Act, Assert
    waitUntil { done in
      _ = GitHub.Explore.collections()
        .subscribe(
          onSuccess: { collections in
            jack.info("Found \(collections.count) collections")

            collections.forEach { c in
              expect(c.items.count) > 0
              if let url = c.logoLocalURL {
                jack.debug("collection logo: \(url.lastPathComponent)", format: .short)
              }
            }

            done()
          },
          onError: { error in
            jack.error(dump(of: error))
            fatalError()
          }
        )
    }
  }

  // MARK: -

  describe("Collection") {

    // MARK: Collection.Item.repository

    it("Collection.Item.repository") {
      let s = "owner/name"
      let c = GitHub.Explore.Collection.Item(string: s)
      expect({
        if case let GitHub.Explore.Collection.Item.repository(owner: o, name: n)? = c {
          if o == "owner" && n == "name" {
            return .succeeded
          } else {
            return .failed(reason: "captured wrong content")
          }
        } else {
          return .failed(reason: "should not return nil")
        }
      }).to(succeed())
    }

    // MARK: Collection.Item.gitHubUser

    it("Item.gitHubUser") {
      let s = "owner"
      let c = GitHub.Explore.Collection.Item(string: s)
      expect({
        if case let GitHub.Explore.Collection.Item.gitHubUser(o)? = c {
          if o == "owner" {
            return .succeeded
          } else {
            return .failed(reason: "captured wrong content")
          }
        } else {
          return .failed(reason: "should not return nil")
        }
      }).to(succeed())
    }

    // MARK: Collection.Item.youtubeVideo

    it("Item.youtubeVideo") {
      let s = "https://www.youtube.com/watch?v=dSl_qnWO104"
      let c = GitHub.Explore.Collection.Item(string: s)
      expect({
        if case GitHub.Explore.Collection.Item.youtubeVideo? = c {
          return .succeeded
        } else {
          return .failed(reason: "should not return nil")
        }
      }).to(succeed())
    }

    // MARK: Collection.Item.site

    it("Item.site") {
      let s = "http://www.163.com"
      let c = GitHub.Explore.Collection.Item(string: s)
      expect({
        if case GitHub.Explore.Collection.Item.site? = c {
          return .succeeded
        } else {
          return .failed(reason: "should not return nil")
        }
      }).to(succeed())
    }

    // MARK: Collection.Item.invalid

    it("Item.site") {
      let s = "- &*name/"
      let c = GitHub.Explore.Collection.Item(string: s)
      expect(c).to(beNil())
    }

  } // describe("Collection")

} }
