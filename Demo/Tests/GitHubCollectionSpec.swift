import XCTest

import Nimble
import Quick

import OHHTTPStubs

@testable import GitHub

import JacKit

class GitHubCollectionSpec: QuickSpec { override func spec() {

  // MARK: Collection.Item.repository

  it("Item.repository") {
    let s = "owner/name"
    let c = GitHub.Collection.Item(string: s)
    expect({
      if case let GitHub.Collection.Item.repository(owner: o, name: n)? = c {
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
    let c = GitHub.Collection.Item(string: s)
    expect({
      if case let GitHub.Collection.Item.gitHubUser(o)? = c {
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
    let c = GitHub.Collection.Item(string: s)
    expect({
      if case GitHub.Collection.Item.youtubeVideo? = c {
        return .succeeded
      } else {
        return .failed(reason: "should not return nil")
      }
    }).to(succeed())
  }

  // MARK: Collection.Item.site

  it("Item.site") {
    let s = "http://www.163.com"
    let c = GitHub.Collection.Item(string: s)
    expect({
      if case GitHub.Collection.Item.site? = c {
        return .succeeded
      } else {
        return .failed(reason: "should not return nil")
      }
    }).to(succeed())
  }

  // MARK: Collection.Item.invalid

  it("Item.site") {
    let s = "- &*name/"
    let c = GitHub.Collection.Item(string: s)
    expect(c).to(beNil())
  }

} }
