import UIKit

import GitHub
import JacKit

private let jack = Jack().set(format: .short)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  )
    -> Bool
  {
    jack.info("short format?")
    Jack().info("short format?")
//    let baseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//
//    let topicTitlesURL = baseURL.appendingPathComponent("topic_titles.txt")
//    let topicSummaryURL = baseURL.appendingPathComponent("topic_summaries.txt")
//    let logosDirecotryURL = baseURL.appendingPathComponent("topic_logos")
//
//    _ = GitHub.Explore.curatedTopics()
//      .subscribe(onSuccess: { topics in
//        // title
//        let titles = topics.map { $0.displayName }.joined(separator: "\n")
//        try! titles.data(using: .utf8)?.write(to: topicTitlesURL)
//
//        // summary
//        let summaries = topics.map { $0.summary }.joined(separator: "\n")
//        try! summaries.data(using: .utf8)?.write(to: topicSummaryURL)
//
//        try? FileManager.default.removeItem(at: logosDirecotryURL)
//        try! FileManager.default.createDirectory(atPath: logosDirecotryURL.path, withIntermediateDirectories: true)
//        topics
//          .compactMap { $0.logoCachedURL }
//          .forEach { url in
//            do {
//              let destURL = logosDirecotryURL.appendingPathComponent(url.lastPathComponent)
//              try FileManager.default.copyItem(at: url, to: destURL)
//              jack.verbose("Copied logo file: \(url.lastPathComponent)")
//            } catch {
//              jack.error("error copying \(url.lastPathComponent): \(error)")
//            }
//          }
//
//        Jack().info("base URL: \(baseURL)")
//      })
//
    return true
  }

}
