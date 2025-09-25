class BackupKeyboardShortcuts < Formula
  desc "Backup and restore user-defined keyboard shortcuts"
  homepage "https://github.com/ElfSundae/backup-keyboard-shortcuts"
  url "https://github.com/ElfSundae/backup-keyboard-shortcuts/archive/refs/tags/0.1.1.tar.gz"
  sha256 "90faccf64c0fe8099c3e7b1e98e374d86de095324da92432bad5fb7812e6b55c"
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
