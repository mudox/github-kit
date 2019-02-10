import Foundation

import Alamofire
import RxSwift

import SSZipArchive
import Yams

import JacKit

private let jack = Jack("GitHub.Explore").set(format: .short)

// MARK: GitHub.Explore

public enum Explore {
  public enum Error: Swift.Error {
    case regexMatchingMarkdownContent
    case downloadCanceled(Data)
  }

  private static var download: Observable<Explore.ListsLoadingState> {
    return .create { observer in

      let url: URLs
      do {
        url = try URLs()
      } catch {
        observer.onError(error)
        return Disposables.create()
      }

      let request = URLRequest(url: url.download)

      let destination: DownloadRequest.DownloadFileDestination = { _, _ in
        (url.downloaded, [.removePreviousFile, .createIntermediateDirectories])
      }

      observer.onNext(.downloading(progress: 0))

      let queue = DispatchQueue(label: "Explore lists downloading progress observing")
      let task = Alamofire.download(request, to: destination)
        .downloadProgress(queue: queue) { progress in
          jack.func().debug("progress: \(progress)")
          observer.onNext(.downloading(progress: progress.fractionCompleted))
        }
        .response { response in
          // Check errors
          if let resumeData = response.resumeData {
            observer.onError(Error.downloadCanceled(resumeData))
            return
          }

          if let error = response.error {
            observer.onError(error)
            return
          }

          // Unarchive
          observer.onNext(.unarchiving)
          SSZipArchive.unzipFile(
            atPath: url.downloaded.path,
            toDestination: url.prefix.path
          )
          observer.onCompleted()
        }

      return Disposables.create { task.cancel() }
    } // .create
  }

  private static var parse: Observable<ListsLoadingState> {
    return .create { observer in
      jack.func().assertBackgroundThread()

      observer.onNext(.parsing)

      // Parse folder
      do {
        let url = try URLs()

        // Curated topics
        let topics = try FileManager.default
          .contentsOfDirectory(atPath: try url.topics.path)
          .flatMap { name -> [CuratedTopic] in
            let indexFile = url.topics.appendingPathComponent("\(name)/index.md")
            if let text = try? String(contentsOf: indexFile) {
              let (yamlString, description) = try parse(markdown: text)
              return [try CuratedTopic(yamlString: yamlString, description: description, directory: name)]
            } else {
              return []
            }
          }

        // Collections
        let collections = try FileManager.default
          .contentsOfDirectory(atPath: try url.collections.path)
          .flatMap { name -> [Collection] in
            let indexFile = url.collections.appendingPathComponent("\(name)/index.md")
            if let text = try? String(contentsOf: indexFile) {
              let (yamlString, description) = try parse(markdown: text)
              return [try Collection(yamlString: yamlString, description: description, directory: name)]
            } else {
              return []
            }
          }

        let lists = Lists(topics: topics, collections: collections)
        observer.onNext(.success(lists))
      } catch {
        observer.onError(error)
      }

      return Disposables.create()
    } // return .create
  }

  public static var lists: Observable<ListsLoadingState> {
    return download
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
      .concat(parse)
  }
}

// MARK: - Types

public extension Explore {
  enum ListsLoadingState {
    case downloading(progress: Double)
    case unarchiving
    case parsing
    case success(Lists)

    public var value: Lists! {
      switch self {
      case let .success(lists):
        return lists
      default:
        return nil
      }
    }
  }

  struct Lists: Codable {
    public let topics: [CuratedTopic]
    public let collections: [Collection]
  }
}

// MARK: - URLs

extension Explore {

  struct URLs {
    let prefix: URL

    init() throws {
      let url = try FileManager.default.url(
        for: .applicationSupportDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
      )
      prefix = url.appendingPathComponent("GitHubKit/GitHubExplore")
    }

    let download = URL(string: "https://github.com/github/explore/archive/master.zip")!

    /// Application Support/GitHubKit/GitHubExplore/downloaded.zip
    var downloaded: URL {
      return prefix.appendingPathComponent("downloaded.zip")
    }

    /// Application Support/GitHubKit/GitHubExplore/explore-master/
    var unzipped: URL {
      return prefix.appendingPathComponent("explore-master")
    }

    /// Application Support/GitHubKit/GitHubExplore/explore-master/topics/
    var topics: URL {
      return unzipped.appendingPathComponent("topics")
    }

    /// Application Support/GitHubKit/GitHubExplore/explore-master/collections/
    var collections: URL {
      return unzipped.appendingPathComponent("collections")
    }
  }

}
