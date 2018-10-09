import Foundation

import Alamofire
import RxAlamofire
import RxSwift

import SSZipArchive
import Yams

import JacKit

public struct GitHubExplore {

  private static let downloadURL = URL(string: "https://github.com/github/explore/archive/master.zip")!

  /// Application Support/GitHubKit/GitHubExplore
  private static let rootDirectoryURL: URL = {
    let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    return url.appendingPathComponent("GitHubKit/GitHubExplore")
  }()

  /// Application Support/GitHubKit/GitHubExplore/master.zip
  private static let downloadedZipFileURL = rootDirectoryURL.appendingPathComponent("downloaded.zip")

  /// Application Support/GitHubKit/GitHubExplore/unzipped
  private static let unzippedDirectoryURL = rootDirectoryURL.appendingPathComponent("explore-master")

  private static var isCached: Bool {
    let jack = Jack("GitHubExplore.isCached").set(options: .short)
    if  FileManager.default.fileExists(atPath: unzippedDirectoryURL.path) {
      jack.verbose("repo github/explore is cached")
      return true
    } else {
      jack.verbose("repo github/explore is NOT cached")
      return false
    }
  }

  // MARK: - Interface

  public enum Error: Swift.Error {
    case regexMatchingMarkdownContent
  }

  public static var synchronize: Completable {

    return .create { completable in
      Jack("GitHubExplore.synchronize").info("download github/explore/master.zip ...")

      let request = URLRequest(url: downloadURL)

      let destination: DownloadRequest.DownloadFileDestination = { _, _ in
        (downloadedZipFileURL, [.removePreviousFile, .createIntermediateDirectories])
      }

      return RxAlamofire.download(request, to: destination)
        .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
        .subscribe(onCompleted: {
          SSZipArchive.unzipFile(
            atPath: downloadedZipFileURL.path,
            toDestination: downloadedZipFileURL.deletingLastPathComponent().path
          )
          completable(.completed)
        })
    } // .create

  }

  public static var loadCuratedTopics: Single<[CuratedTopic]> {
    return .create { single in

      // Parse folder
      do {
        let topicsDirectoryURL = unzippedDirectoryURL.appendingPathComponent("topics")

        let curatedTopics = try FileManager.default
          .contentsOfDirectory(atPath: topicsDirectoryURL.path)
          // Append `/topics/index.md`
          .map { path -> URL in
            let markdownPath = path.appending("/index.md")
            return unzippedDirectoryURL.appendingPathComponent("/topics/\(markdownPath)")
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
    } // return .create
  }

  /// Scan the downloaded 'github/explore' folder, parse each 'topics/\*/index.md'
  /// file as an instance of `GitHubExplore.CuratedTopic`.
  public static func curatedTopics(aftreSync sync: Bool = false) -> Single<[CuratedTopic]> {
    if !isCached || sync {
      return synchronize.andThen(loadCuratedTopics)
    } else {
      return loadCuratedTopics
    }
  }

  public static var loadCollections: Single<[Collection]> {
    return .create { single in

      // Unzip
      SSZipArchive.unzipFile(
        atPath: downloadedZipFileURL.path,
        toDestination: downloadedZipFileURL.deletingLastPathComponent().path
      )

      // Parse folder
      do {
        let collectionsDirectoryURL = unzippedDirectoryURL.appendingPathComponent("collections")

        let collections = try FileManager.default
          .contentsOfDirectory(atPath: collectionsDirectoryURL.path)
          // Append `/collections/index.md`
          .map { path -> URL in
            let markdownPath = path.appending("/index.md")
            return unzippedDirectoryURL.appendingPathComponent("/collections/\(markdownPath)")
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

  /// Scan the downloaded 'github/explore' folder, parse each 'collections/\*/index.md'
  /// file as an instance of `GitHubExplore.Collection`.
  public static func collections(afterSync sync: Bool = false) -> Single<[Collection]> {
    if !isCached || sync {
      return synchronize.andThen(loadCollections)
    } else {
      return loadCollections
    }
  }

}
