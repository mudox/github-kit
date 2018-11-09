Pod::Spec.new do |s|
  s.name             = 'GitHubKit'
  s.module_name      = 'GitHub'
  s.version          = '0.2.0'
  s.summary          = 'Yet another Swift implementation of GitHub API v3 (RESTful)'

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  Yet another Swift implementation of GitHub API v3 (RESTful).
  DESC

  s.homepage         = 'https://github.com/mudox/github-kit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'mudox' => 'imudox@gmail.com' }
  s.source           = { :git => 'https://github.com/mudox/github-kit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'Source/**/*.swift'

  # s.resource_bundles = {
  #   'GitHubKit' => ['GitHubKit/Assets/*.png']
  # }

  s.dependency 'JacKit'

  s.dependency 'RxAlamofire'
  s.dependency 'Moya/RxSwift'

  s.dependency 'RxSwift'
  s.dependency 'RxCocoa'

  s.dependency 'SSZipArchive'

  s.dependency 'Yams'

  s.dependency 'Kanna'
  s.pod_target_xcconfig = { 'HEADER_SEARCH_PATHS' => "$(SDKROOT)/usr/include/libxml2" }

end
