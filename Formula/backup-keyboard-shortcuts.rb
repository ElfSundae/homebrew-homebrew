class BackupKeyboardShortcuts < Formula
  desc "Backup and restore user-defined keyboard shortcuts"
  homepage "https://github.com/ElfSundae/backup-keyboard-shortcuts"
  url "https://github.com/ElfSundae/backup-keyboard-shortcuts/archive/refs/tags/0.1.0.tar.gz"
  sha256 "1da584ea699334c71e1e92360acb3f8eca8f9a91c8ae16f38b42f52e9d7fd16d"
  license "MIT"

  depends_on "jq"
  depends_on :macos

  def install
    bin.install "backup-keyboard-shortcuts"
  end

  test do
    system bin/"backup-keyboard-shortcuts", "--help"
  end
end
