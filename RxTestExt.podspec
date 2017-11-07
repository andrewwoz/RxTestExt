Pod::Spec.new do |s|

  s.name         = "RxTestExt"
  s.version      = "0.1.0"
  s.summary      = "A collection of operators & tools not found in the core RxTest distribution."

  s.description  = <<-DESC
  Provide developers with extensions for RxTest. The library includes a set of extensions for test schedulers and assertions on testable observers.
                   DESC

  s.homepage     = "https://github.com/mosamer/RxTestExt"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "mosamer" => "mostafamamer@gmail.com" }
  s.source       = { :git => 'https://github.com/mosamer/RxTestExt.git', :tag => s.version.to_s }

  s.ios.deployment_target = "9.0"

  s.default_subspec = 'Core'
  
  s.subspec 'Core' do |cs|
    s.source_files = 'RxTestExt/Core/**/*'
  end
  
  s.dependency 'RxTest', '~> 4.0.0'
end
