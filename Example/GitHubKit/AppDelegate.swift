import UIKit

import GitHubKit

import JacKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    _ = GitHubTrending.developers()
      .subscribe(
        onSuccess: { _ in
          print("done")
        },
        onError: { error in
          dump(error)
        }
      )

    return true
  }

}
