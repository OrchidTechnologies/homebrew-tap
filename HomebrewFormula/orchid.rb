class Orchid < Formula
  include Language::Python::Virtualenv
  desc "Orchid VPN Client CLI"
  homepage "https://www.orchid.com"
  url "https://github.com/OrchidTechnologies/orchid.git", :using => :git, :revision => "b223f47e1adb49a5587166f65c6b8eb518c15ae5"
  version "0.9.5.p222.gb223f47"
  revision 1
  head "https://github.com/OrchidTechnologies/orchid.git", :using => :git


  bottle do
    root_url "https://dl.bintray.com/orchidprotocol/bottles"
    cellar :any_skip_relocation
    sha256 "e1854218effa2cc622816b395db6f3ef3a76c369916b5346eb8b3a5759331b0f" => :catalina
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "coreutils" => :build
  depends_on "gettext" => :build
  depends_on "help2man" => :build
  depends_on "libtool" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "python" => :build

  resource "PyYAML" do
    url "https://files.pythonhosted.org/packages/9e/a3/1d13970c3f36777c583f136c136f804d70f500168edc1edea6daa7200769/PyYAML-3.13.tar.gz"
    sha256 "3ef3092145e9b70e3ddd2c7ad59bdd0252a94dfe3949721633e41344de00a6bf"
  end

  def install
    system "git", "config", "--global", 'url."git://git.savannah.gnu.org/".insteadOf', "https://git.savannah.gnu.org/git/"
    system "git", "config", "--global", 'url."git://git.savannah.nongnu.org/".insteadOf', "https://git.savannah.nongnu.org/git/"
    system "git", "config", "--global", "advice.detachedHead", "false"
    system "git", "submodule", "update", "--init", "--recursive"
    resource("PyYAML").stage { system "python", *Language::Python.setup_install_args(libexec/"vendor") }
    system "make", "-C", "cli-shared"

    (buildpath/"man_wrapper.sh").write <<~EOS
      #!/bin/bash

      if [ "$1" = "--version" ] ; then
        echo 'orchid 1.bogus'
      fi
      echo 'Usage: orchid [OPTION]...'
      echo 'Connect to Orchid'
      echo
      ./cli-shared/out-mac/x86_64/orchid --help 2>&1 | tail -n +3 | tac | tail -n +3 | tac
    EOS

    chmod 0755, buildpath/"man_wrapper.sh"
    chmod 0755, "./cli-shared/out-mac/x86_64/orchid"
    system buildpath/"man_wrapper.sh"

    system "help2man", "--no-info", "--section", "8", "--output", "orchid.8", "--name", "Connect to Orchid", "--version-string", "orchid #{version}", buildpath/"man_wrapper.sh"
    bin.install "cli-shared/out-mac/x86_64/orchid"
    man8.install "orchid.8"
  end

  test do
    system "#{bin}/orchid", "--help"
  end
end
