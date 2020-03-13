class Orchid < Formula
  desc "Orchid VPN Client CLI"
  homepage "https://www.orchid.com"
  url "https://github.com/OrchidTechnologies/orchid.git", :using => :git, :revision => "b223f47e1adb49a5587166f65c6b8eb518c15ae5"
  version "0.9.5.p222.gb223f47"
  head "https://github.com/OrchidTechnologies/orchid.git", :using => :git

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "gettext" => :build
  depends_on "libtool" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "python" => :build

  def install
    system "git", "config", "--global", 'url."git://git.savannah.gnu.org/".insteadOf', "https://git.savannah.gnu.org/git/"
    system "git", "config", "--global", 'url."git://git.savannah.nongnu.org/".insteadOf', "https://git.savannah.nongnu.org/git/"
    system "git", "config", "--global", "advice.detachedHead", "false"
    system "git", "submodule", "update", "--init", "--recursive"
    system "python", "-m", "pip", "install", "pyyaml"
    system "make", "-C", "cli-shared"
    bin.install "cli-shared/out-mac/x86_64/orchid"
  end

  test do
    system "#{bin}/orchid", "--help"
  end
end
