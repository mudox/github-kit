import Foundation

import Kanna

import JacKit

fileprivate extension Jack {
  func cssError(tag: String, css: String) {
    error("css selecting title <\(tag)> (`\(css)`) returned empty set")
  }

  func emptyError(subject: String) {
    error("\(subject) is empty")
  }
}

extension GitHubTrending {

  public struct Repository {

    enum Error: Swift.Error {
      case htmlDocInit
      case emptyCSSSelector(String)
    }

    let title: String
    let description: String

    let language: (name: String, color: String)?

    let starsCount: Int
    let forksCount: Int
//  let gainedStarsCount: Int
//
//  let contibutors: [String]

    public init?(from item: Kanna.XMLElement) {
      let jack = Jack("Tending.init")

      /*
       *
       * Step 1 - Title
       *
       */

      guard let link = item.css("h3 a").first else {
        jack.cssError(tag: "title <div", css: "h3 a")
        return nil
      }

      // title
      guard let title = link.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
        jack.emptyError(subject: "title <a>.text")
        return nil
      }

      self.title = title

      /*
       *
       * Step 2 - Description
       *
       */

      guard let descDiv = item.css("div:nth-child(3)").first else {
        jack.cssError(tag: "description <div>", css: "div:nth-child(3)")
        return nil
      }

      guard let text = descDiv.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
        jack.emptyError(subject: "description <div>.text")
        return nil
      }

      description = text

      /*
       *
       * Step 3 - Bar
       *
       */

      guard let barDiv = item.css("div:nth-child(4)").first else {
        jack.cssError(tag: "bar description <div>", css: "div:nth-child(4)")
        return nil
      }

      // The bar comprises of 4 or 5 components with language part optional.
      let languageSpan: XMLElement?
      let starsAnchor: XMLElement
      let forksAnchor: XMLElement
      let contributorsSpan: XMLElement
      let gainedStarsSpan: XMLElement

      // 2 or 3 spans
      let spans = barDiv.css("span[class^='d-inline-block']")
      if spans.count == 2 {
        languageSpan = nil
        contributorsSpan = spans[0]
        gainedStarsSpan = spans[1]
      } else if spans.count == 3 {
        languageSpan = spans[0]
        contributorsSpan = spans[1]
        gainedStarsSpan = spans[2]
      } else {
        jack.error("invlaid bar div structure, expecting 2 or 3 spans")
        return nil
      }

      // Stars and forks anchor
      if let anchor = barDiv.css("a[href$=stargazers]").first {
        starsAnchor = anchor
      } else {
        jack.cssError(tag: "stars <a>", css: "a:nth-child(1)")
        return nil
      }
      if let anchor = barDiv.css("a[href$=network]").first {
        forksAnchor = anchor
      } else {
        jack.cssError(tag: "stars <a>", css: "a:nth-child(1)")
        return nil
      }

      // Language span
      if languageSpan == nil {
        language = nil
      } else {
        // Parsing language span
        let color: String?
        let name: String?
        if
          let spans = languageSpan?.css("span"),
          spans.count == 2
        {
          // language color
          let span0 = spans[0]
          if
            let style = span0["style"] as? NSString,
            let regex = try? NSRegularExpression(pattern: "#(.*);"),
            let match = regex.firstMatch(in: style as String, options: [], range: NSRange(location: 0, length: style.length))
          {
            color = style.substring(with: match.range(at: 1))
          } else {
            color = nil
          }
          // language
          let span1 = spans[1]
          name = span1.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
          color = nil
          name = nil
        }

        if name != nil && color != nil {
          language = (name: name!, color: color!)
        } else {
          language = nil
        }

      }

      guard let starsText = starsAnchor.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
        jack.emptyError(subject: "stars <a>")
        return nil
      }

      let formatter = NumberFormatter()
      formatter.numberStyle = .decimal

      guard let starsCount = formatter.number(from: starsText) else {
        jack.error("invalid stars count text: \(starsText)")
        return nil
      }
      self.starsCount = starsCount.intValue

      guard let forksText = forksAnchor.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
        jack.emptyError(subject: "forks <a>")
        return nil
      }
      guard let forksCount = formatter.number(from: forksText) else {
        jack.error("invalid stars count text: \(forksText)")
        return nil
      }
      self.forksCount = forksCount.intValue

    }

    public static func trendings(from htmlString: String) -> [GitHubTrending.Repository]? {

      let jack = Jack("Trending.trendingsMapping")

      guard let doc = try? HTML(html: htmlString, encoding: .utf8) else {
        jack.error("init `Kanna.HTML` failed")
        return nil
      }

      let items = doc.css("ol.repo-list li")
      jack.info("found \(items.count) items", options: .short)

      // swiftlint:disable:next empty_count
      guard items.count > 0 else {
        jack.error("css selecting `ol.repo-list li` returned empty set")
        return nil
      }

      var trendings = [GitHubTrending.Repository]()
      for item in items {
        if let trending = GitHubTrending.Repository(from: item) {
          trendings.append(trending)

          let languageText = trending.language.flatMap { name, color in
            return "\(name), #\(color)"
          }

          jack.debug("""
          title:           \(trending.title)
          description:     \(trending.description)
          --
          language style:  \(languageText ?? "n/a")
          stars:           \(trending.starsCount)
          forks:           \(trending.forksCount)
          """, options: .noLocation)

        } else {
          jack.warn("init Trending instance failed")
          continue
        }
      } // for item in items

      return trendings

    } // func trendings(from:)

  }
}
