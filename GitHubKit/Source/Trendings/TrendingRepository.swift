import Foundation

import Kanna

import JacKit

fileprivate extension Jack {
  func cssError(tag: String, css: String) {
    error("css selecting \(tag) (`\(css)`) returned empty set")
  }

  func emptyError(subject: String) {
    error("\(subject) is empty")
  }

  func countError(subject: String, text: String) {
    error("invalid count number text: \(text)")
  }
}

public extension GitHubTrending {

  struct Repository {

    let title: String
    let description: String

    let language: (name: String, color: String)?

    let starsCount: Int
    let forksCount: Int
    let gainedStarsCount: Int
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
      let forksAnchor: XMLElement?
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
          guard let style = span0["style"] else {
            jack.emptyError(subject: "language color <span> style attribute")
            return nil
          }

          guard let languageColorString = Repository.colorString(from: style) else {
            jack.error("extract color text from language color <span> sytle attribute failed")
            return nil
          }
          color = languageColorString

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

      // Stars anchor
      if let anchor = barDiv.css("a[href$=stargazers]").first {
        starsAnchor = anchor
      } else {
        jack.cssError(tag: "stars <a>", css: "a[href$=stargazers]")
        return nil
      }

      // Stars count
      guard let starsCount = Repository.number(from: starsAnchor, subject: "stars <a>") else { return nil }
      self.starsCount = starsCount

      // Forks anchor (optional)
      if let anchor = barDiv.css("a[href$=network]").first {
        forksAnchor = anchor
      } else {
        jack.cssError(tag: "forks <a>", css: "a[href$=network]")
        forksAnchor = nil
      }

      // Forks count
      if let anchor = forksAnchor {
        guard let forksCount = Repository.number(from: anchor, subject: "forks <a>") else { return nil }
        self.forksCount = forksCount
      } else {
        forksCount = 0
      }

      // Gained stars count
      guard let gainedStarsText = gainedStarsSpan.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
        jack.emptyError(subject: "gained stars <span>")
        return nil
      }
      guard let gainedStarsCount = Repository.starsCount(from: gainedStarsText) else {
        jack.error("extract stars number from gained stars <span> failed")
        return nil
      }

      self.gainedStarsCount = gainedStarsCount

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
          language:        \(languageText ?? "n/a")
          stars:           \(trending.starsCount)
          forks:           \(trending.forksCount)
          gained stars:    \(trending.gainedStarsCount)
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

// MARK: - Parsing helpers

internal extension GitHubTrending.Repository {

  static func colorString(from text: String) -> String? {
    let nsText = text as NSString
    let nsRange = NSRange(location: 0, length: nsText.length)
    let pattern = "background-color\\s*:\\s*#([^;]+);"

    guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
    guard let match = regex.firstMatch(in: text, options: [], range: nsRange) else { return nil }

    return nsText.substring(with: match.range(at: 1))
  }

  static func starsCount(from text: String) -> Int? {
    let nsText = text as NSString
    let nsRange = NSRange(location: 0, length: nsText.length)
    let pattern = "(\\d+)\\s*stars"

    guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
    guard let match = regex.firstMatch(in: text, options: [], range: nsRange) else { return nil }

    let digitsText = nsText.substring(with: match.range(at: 1)) as String
    return Int(digitsText)
  }

  static func number(from element: XMLElement, subject: String) -> Int? {
    let jack = Jack("GitHubTrending.Repository")

    // element -> text
    guard let text = element.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
      jack.emptyError(subject: subject)
      return nil
    }

    // text -> number
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    guard let number = formatter.number(from: text) else {
      jack.countError(subject: subject, text: text)
      return nil
    }

    return number.intValue
  }
}
