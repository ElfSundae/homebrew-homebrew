cask "quicklookapk2" do
  version "1.1.0"
  sha256 "ee7f98a6bf3fff38d4d3cbe7f1445bb9fbbb329045680861a8b002b3ff379415"

  url "https://github.com/ElfSundae/QuickLookAPK/releases/download/#{version}/QuickLookAPK.qlgenerator-v#{version}.zip"
  name "QuickLookAPK"
  desc "Quick Look plugin for Android packages"
  homepage "https://github.com/ElfSundae/QuickLookAPK"

  deprecate! date: "2025-09-22", because: :no_longer_meets_criteria

  conflicts_with cask: "quicklookapk"

  qlplugin "QuickLookAPK.qlgenerator"
end
