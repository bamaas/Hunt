class Hunt < Formula
  desc "Fuzzy finder for files, grep, directories, and zoxide jump - all in one"
  homepage "https://github.com/bamaas/Hunt"
  url "https://github.com/bamaas/Hunt/archive/refs/tags/v0.1.1.tar.gz"
  version "0.1.1"
  sha256 "2c2ba8f9bf9812789f0d7b3c38bc4fbe72c3201643b2fcaca0bcce8970c3aeb3"
  license "MIT"

  depends_on "fzf"
  depends_on "fd"
  depends_on "ripgrep"
  depends_on "bat"
  depends_on "zoxide"
  depends_on "eza"

  def install
    (share/"hunt").install "hunt.sh"
  end

  def caveats
    <<~EOS
      Add the following to your ~/.zshrc:
        source #{opt_share}/hunt/hunt.sh
    EOS
  end

  test do
    assert_match "hunt()", shell_output("cat #{opt_share}/hunt/hunt.sh")
  end
end
