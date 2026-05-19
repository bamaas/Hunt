class Hunt < Formula
  desc "Fuzzy finder for files, grep, directories, and zoxide jump - all in one"
  homepage "https://github.com/bamaas/Hunt"
  url "https://github.com/bamaas/Hunt/archive/refs/tags/v0.1.2.tar.gz"
  version "0.1.2"
  sha256 "0b53a1067222470b5e520ea27e2416a02696fa543699a60c906b945d57468f11"

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
