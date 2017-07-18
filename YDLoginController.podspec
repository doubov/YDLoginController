Pod::Spec.new do |s|

  	s.name         	= "YDLoginController"
	s.version      	= "1.0.0"
	s.summary      	= "An easy-to-use Swift 3 login controller."

	s.description  	= "The Swift 3 login controller designed to be universally re-usable for various applications. "

	s.homepage     	= "https://github.com/doubov/YDLoginController"
	s.license      	= "Proprietary license"

	s.author		= { "Yuri Doubov" => "doubov@gmail.com" }
	s.platform     	= :ios, "10.0"
	s.ios.deployment_target = "10.0"

	s.source       	= { :git => "https://github.com/doubov/YDLoginController.git", :tag => s.version }
	s.source_files 	= "Source/*.swift"
	s.resources 	= ['Resource/*.png']
end
