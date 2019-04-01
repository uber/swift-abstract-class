Pod::Spec.new do |s|
  s.name             = 'AbstractClassFoundation'
  s.version          = ''
  s.summary          = 'Swift abstract class validator.'
  s.description      = 'Swift abstract class validator is an source code analysis tool that validates abstract class rules.'

  s.homepage         = 'https://github.com/uber/swift-abstract-class'
  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE.txt' }
  s.author           = { 'Yi Wang' => 'yiw@uber.com' }

  s.source           = { :git => 'https://github.com/uber/swift-abstract-class.git', :tag => "v" + s.version.to_s }
  s.source_files     = 'Sources/**/*.swift'
  s.ios.deployment_target = '8.0'
  s.swift_version    = '4.2'
end
