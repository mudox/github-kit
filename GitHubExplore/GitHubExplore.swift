import Foundation

import Alamofire
import RxAlamofire
import RxSwift

import SSZipArchive
import Yams

import JacKit

public struct GitHubExplore {

  fileprivate static let downloadURL = URL(string: "https://github.com/github/explore/archive/master.zip")!

  fileprivate static let zipURL: URL = {
    let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    return url.appendingPathComponent("GitHubKit/GitHubExplore/master.zip")
  }()

  fileprivate static let url: URL = {
    zipURL
      .deletingPathExtension()
      .appendingPathComponent("explore-master")
  }()

  // MARK: - Interface

  public enum Error: Swift.Error {
    case regexMatchMarkdownContent
  }

  public static var synchronize: Completable {

    return .create { completable in

      let request = URLRequest(url: downloadURL)

      let destination: DownloadRequest.DownloadFileDestination = { _, _ in
        (zipURL, [.removePreviousFile, .createIntermediateDirectories])
      }

      return RxAlamofire.download(request, to: destination)
        .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
        .subscribe(onCompleted: {
          SSZipArchive.unzipFile(
            atPath: zipURL.path,
            toDestination: zipURL.deletingLastPathComponent().path
          )
          completable(.completed)
        })
    } // .create

  }

  /// Scan the downloaded 'github/explore' folder, parse each 'topics/\*/index.md'
  /// file as an instance of `GitHubExplore.CuratedTopic`.
  public static var curatedTopics: Single<[CuratedTopic]> {
    return .create { single in

      // Parse folder
      do {
        let topicsDirectoryURL = url.appendingPathComponent("topics")

        let curatedTopics = try FileManager.default
          .contentsOfDirectory(atPath: topicsDirectoryURL.path)
          // Append `/topics/index.md`
          .map { path -> URL in
            let markdownPath = path.appending("/index.md")
            return url.appendingPathComponent("/topics/\(markdownPath)")
          }
          // Filter out non-existing files.
          .filter { url in
            FileManager.default.fileExists(atPath: url.path)
          }
          // Parse each `index.md` file as an instance of `GitHubExplore.CuratedTopic`
          .map { url -> CuratedTopic in
            let text = try String(contentsOf: url)
            let (yamlString, description) = try parse(text: text)
            return try CuratedTopic(yamlString: yamlString, description: description)
          }

        single(.success(curatedTopics))
      } catch {
        single(.error(error))
      }

      return Disposables.create()
    }
  }

  /// Scan the downloaded 'github/explore' folder, parse each 'collections/\*/index.md'
  /// file as an instance of `GitHubExplore.Collection`.
  public static var collections: Single<[Collection]> {
    return .create { single in

      // Unzip
      SSZipArchive.unzipFile(
        atPath: zipURL.path,
        toDestination: zipURL.deletingLastPathComponent().path
      )

      // Parse folder
      do {
        let collectionsDirectoryURL = url.appendingPathComponent("collections")

        let collections = try FileManager.default
          .contentsOfDirectory(atPath: collectionsDirectoryURL.path)
          // Append `/collections/index.md`
          .map { path -> URL in
            let markdownPath = path.appending("/index.md")
            return url.appendingPathComponent("/collections/\(markdownPath)")
          }
          // Filter out non-existing files.
          .filter { url in
            FileManager.default.fileExists(atPath: url.path)
          }
          // Parse each `index.md` file as an instance of `GitHubExplore.Collection`
          .map { url -> Collection in
            let text = try String(contentsOf: url)
            let (yamlString, description) = try parse(text: text)
            return try Collection(yamlString: yamlString, description: description)
          }

        single(.success(collections))
      } catch {
        single(.error(error))
      }

      return Disposables.create()
    }
  }

}
