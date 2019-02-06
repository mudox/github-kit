import Foundation

import Alamofire
import RxAlamofire
import RxSwift

import SSZipArchive
import Yams

import JacKit

private let jack = Jack("GitHub.Explore").set(format: .short)

// MARK: GitHub.Explore

public enum Explore {

  public enum Error: Swift.Error {
    case regexMatchingMarkdownContent
  }

  private static var download: Completable {

    return .create { completable in
      let request = URLRequest(url: .download)

      let destination: DownloadRequest.DownloadFileDestination = { _, _ in
        (.downloaded, [.removePreviousFile, .createIntermediateDirectories])
      }

      return RxAlamofire.download(request, to: destination)
        .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
        .subscribe(onCompleted: {
          SSZipArchive.unzipFile(
            atPath: URL.downloaded.path,
            toDestination: URL.downloaded.deletingLastPathComponent().path
          )
          completable(.completed)
        })
    } // .create

  }

  private static var parse: Single<Lists> {

    return .create { single in
      jack.func().assertBackgroundThread()

      // Parse folder
      do {

        // Curated topics

        let topics = try FileManager.default
          // For each directory in `topics` folder
          .contentsOfDirectory(atPath: URL.topics.path)
          // Append `index.md`
          .map { path -> URL in
            return URL.topics.appendingPathComponent("\(path)/index.md")
          }
          // Filter out non-existing files.
          .filter { url in
            FileManager.default.fileExists(atPath: url.path)
          }
          // Parse each `index.md` file as an instance of `GitHub.CuratedTopic`
          .map { url -> CuratedTopic in
            let baseDir = url.deletingLastPathComponent()
            let text = try String(contentsOf: url)
            let (yamlString, description) = try parse(text: text)
            return try CuratedTopic(yamlString: yamlString, description: description, baseDir: baseDir)
          }

        // Collections

        let collections = try FileManager.default
          // For each directory in `collections` folder
          .contentsOfDirectory(atPath: URL.collections.path)
          // Append `index.md`
          .map { path -> URL in
            return URL.collections.appendingPathComponent("\(path)/index.md")
          }
          // Filter out non-existing files.
          .filter { url in
            FileManager.default.fileExists(atPath: url.path)
          }
          // Parse each `index.md` file as an instance of `GitHub.Explore.Collection`
          .map { url -> Collection in
            let baseDir = url.deletingLastPathComponent()
            let text = try String(contentsOf: url)
            let (yamlString, description) = try parse(text: text)
            return try Collection(yamlString: yamlString, description: description, baseDir: baseDir)
          }

        single(.success(Lists(topics: topics, collections: collections)))
      } catch {
        single(.error(error))
      }

      return Disposables.create()
    } // return .create
  }

  public static var lists: Single<Lists> {
    return download
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .default))
      .andThen(parse)
  }

}

// MARK: - GitHub.Explore.Lists

public extension Explore {

  struct Lists: Codable {
    public let topics: [CuratedTopic]
    public let collections: [Collection]
  }

}

// MARK: - URLs

private extension URL {

  static let download = URL(string: "https://github.com/github/explore/archive/master.zip")!

  /// Application Support/GitHubKit/GitHub.Explore/
  static let prefix: URL = {
    let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    return url.appendingPathComponent("GitHubKit/GitHub.Explore")
  }()

  /// Application Support/GitHubKit/GitHub.Explore/downloaded.zip
  static let downloaded = prefix.appendingPathComponent("downloaded.zip")

  /// Application Support/GitHubKit/GitHub.Explore/explore-master/
  static let unzipped = prefix.appendingPathComponent("explore-master")

  /// Application Support/GitHubKit/GitHub.Explore/explore-master/topics/
  static let topics = unzipped.appendingPathComponent("topics")
  /// Application Support/GitHubKit/GitHub.Explore/explore-master/collections/
  static let collections = unzipped.appendingPathComponent("collections")

}
