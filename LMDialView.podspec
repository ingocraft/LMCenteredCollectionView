Pod::Spec.new do |s|
  s.name         = "LMDialView"
  s.version      = "0.1.0"
  s.summary      = "Dial, scale, graduation, calibration."

  s.homepage     = "https://github.com/ingocraft/LMDialView"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "Liam" => "ingocraft118@gmail.com" }

  s.platform     = :ios, "10.0"

  s.swift_version = "5.0"
  s.swift_versions = ["4.0", "4.2", "5.0"]

  s.source       = { :git => "https://github.com/ingocraft/LMDialView.git", :tag => s.version }

  s.source_files  = ["Sources/**/*.swift", "Sources/LMDialView.h"]
  s.public_header_files = "Sources/LMDialView.h"
end
