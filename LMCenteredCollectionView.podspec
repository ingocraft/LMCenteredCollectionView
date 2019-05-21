Pod::Spec.new do |s|
  s.name         = "LMCenteredCollectionView"
  s.version      = "0.0.4"
  s.summary      = "infinite, centered, collection view."

  s.homepage     = "https://github.com/ingocraft/LMCenteredCollectionView"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "Liam" => "ingocraft118@gmail.com" }

  s.platform     = :ios, "10.0"

  s.swift_version = "5.0"
  s.swift_versions = ["4.0", "4.2", "5.0"]

  s.source       = { :git => "https://github.com/ingocraft/LMCenteredCollectionView.git", :tag => s.version }

  s.source_files  = ["Sources/**/*.swift", "Sources/LMCenteredCollectionView.h"]
  s.public_header_files = "Sources/LMCenteredCollectionView.h"
end
