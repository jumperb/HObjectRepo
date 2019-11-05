Pod::Spec.new do |s|

  s.name         = "HObjectRepo"
  s.version      = "1.0.1"
  s.summary      = "It's a object storage"

  s.description  = <<-DESC
                   A longer description of HObjectRepo in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "http://EXAMPLE/HObjectRepo"
  
  s.author             = { "zct" => "zhangchutian_05@163.com" }

    s.source       = { :git => "https://github.com/jumperb/HObjectRepo.git", :tag => s.version.to_s}

  s.source_files  = 'Classes/**/*.{h,m}'
  
  s.dependency 'HAccess/Entity'
  s.dependency 'HCache'
  s.requires_arc = true
  
  s.ios.deployment_target = '8.0'
  
end
