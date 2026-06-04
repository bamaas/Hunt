class Hunt < Formula
  desc "Fuzzy finder for files, grep, directories, and zoxide jump - all in one"
  homepage "https://github.com/bamaas/Hunt"
  url "https://github.com/bamaas/Hunt/archive/refs/tags/v0.1.3.tar.gz"
  version "0.1.3"
  sha256 "fecca50989542df2b4c64182e5b66df780522db74e85c22fda57788fc43fe98e"

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
