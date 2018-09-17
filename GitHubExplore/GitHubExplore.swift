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

  internal static var download: Completable {

    return .create { completable in

      let request = URLRequest(url: downloadURL)

      let destination: DownloadRequest.DownloadFileDestination = { _, _ in
        (zipURL, [.removePreviousFile, .createIntermediateDirectories])
      }

      return RxAlamofire.download(request, to: destination)
        .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
        .subscribe(onCompleted: {
          Jack("GitHubExplore.download").info("completed", options: .short)
          completable(.completed)
        })
    } // .create

  }

  internal static var parse: Single<[CuratedTopic]> {
    return .create { single in

      // Unzip
      SSZipArchive.unzipFile(
        atPath: zipURL.path,
        toDestination: zipURL.deletingLastPathComponent().path
      )
      Jack("GitHubExplore.parse.unzip").info("completed", options: .short)

      // Parse folder
      do {
        let topicsDirectoryURL = url.appendingPathComponent("topics")
        let indexFileURLs = try FileManager.default
          .contentsOfDirectory(atPath: topicsDirectoryURL.path)
          .map { path -> URL in
            let filePath = path.appending("/index.md")
            return url.appendingPathComponent("/topics/\(filePath)")
          }
          .filter { FileManager.default.fileExists(atPath: $0.path) }
        Jack("GitHubExplore.parse.filemanager").debug("found totally \(indexFileURLs.count) index.md files")
        single(.success(try indexFileURLs.map(CuratedTopic.init)))
        Jack("GitHubExplore.parse").info("completed", options: .short)
      } catch {
        single(.error(error))
        Jack("GitHubExplore.parse").error("failed", options: .short)
      }

      return Disposables.create()
    }
  }

  public static func test() -> Single<[CuratedTopic]> {
    return download.andThen(parse)
  }

}
