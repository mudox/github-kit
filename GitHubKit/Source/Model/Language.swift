import Foundation

import RxAlamofire
import RxSwift

import JacKit

public struct Language {

  private static let url1 = URL(string: "https://raw.githubusercontent.com/ozh/github-colors/master/colors.json")
  private static let url2 = URL(string: "https://github.com/doda/github-language-colors/blob/master/colors.json")

  private static let githubLanguagesDirectoryURL: URL = {
    let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    return url.appendingPathComponent("GitHubKit/GitHubLanguages")
  }()

  private static let githubLanguagesFielURL: URL = {
    return githubLanguagesDirectoryURL.appendingPathComponent("languages")
  }()

  /// Download and merge the 2 sources of all GitHub languages and their colors.
  internal static var synchronize: Completable {
    fatalError("Unimplemented")
  }

  internal static var isChached: Bool {
    return FileManager.default.fileExists(atPath: githubLanguagesFielURL.path)
  }

  public static var all: Single<[Language]> {
    fatalError("Unimplemented")
  }

}
