import XCTest

import Nimble
import Quick

import GitHubKit

class ModelSpec: QuickSpec { override func spec() {

  // MARK: Pagination

  describe("Pagination") {

    it("repsents single page") {
      // Act

      var p: Pagination?
      expect {
        p = try Pagination(from: [:])
      }.notTo(throwError())
      
      switch p! {
      case .single:
        break
      default:
        fatalError()
      }

      expect(p!.pageIndex) == 0
      expect(p!.totalCount) == 1

    }

    it("repsents first page") {
      // Arrange
      let text = """
      <https://api.com/search/repositories?q=neovim&sort=stars&order=desc&page=2>; rel="next", \
      <https://api.com/search/repositories?q=neovim&sort=stars&order=desc&page=34>; rel="last"
      """

      // Act
      let p = try! Pagination(from: ["Link": text])

      // Assert
      expect(p.pageIndex) == 0
      expect(p.totalCount) == 34
    }

    it("repsents middle page") {
      // Arrange
      let text = """
      <https://api.com/search/repositories?q=neovim&sort=stars&order=desc&page=1>; rel="prev", \
      <https://api.com/search/repositories?q=neovim&sort=stars&order=desc&page=3>; rel="next", \
      <https://api.com/search/repositories?q=neovim&sort=stars&order=desc&page=34>; rel="last", \
      <https://api.com/search/repositories?q=neovim&sort=stars&order=desc&page=1>; rel="first"
      """

      // Act
      let p = try! Pagination(from: ["Link": text])

      // assert
      expect(p.pageIndex) == 2
      expect(p.totalCount) == 34
    }

    it("repsents last page") {
      // Arrange
      let text = """
      <https://api.com/search/repositories?q=neovim&sort=stars&order=desc&page=33>; rel="prev", \
      <https://api.com/search/repositories?q=neovim&sort=stars&order=desc&page=1>; rel="first"
      """

      // Act
      let p = try! Pagination(from: ["Link": text])

      // Assert
      expect(p.pageIndex) == 34
      expect(p.totalCount) == 34
    }

  }

  // MARK: RateLimit

  describe("RateLimit") {

    it("init from response header fields") {
      // Arrange
      let headers = [
        "X-RateLimit-Limit": "30",
        "X-RateLimit-Reset": "1536306663",
        "X-RateLimit-Remaining": "29",
      ]

      // Act & Assert
      let rateLimit = HeaderRateLimit(from: headers)
      expect(rateLimit).toNot(beNil())
      dump(rateLimit!)
    }

  }

} }
