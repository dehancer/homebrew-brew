# https://github.com/Homebrew/homebrew-core/commits/main/Formula/x/xz.rb
# 69f877707ea5f604dce180d59b9c8f243416d2de

class XzDehancer < Formula
  desc "General-purpose data compression with high compression ratio"
  homepage "https://tukaani.org/xz/"
  url "https://github.com/tukaani-project/xz/releases/download/v5.8.3/xz-5.8.3.tar.gz"
  mirror "https://downloads.sourceforge.net/project/lzmautils/xz-5.8.3.tar.gz"
  mirror "http://downloads.sourceforge.net/project/lzmautils/xz-5.8.3.tar.gz"
  sha256 "3d3a1b973af218114f4f889bbaa2f4c037deaae0c8e815eec381c3d546b974a0"
  license all_of: [
    "0BSD",
    "GPL-2.0-or-later",
  ]
  version_scheme 1
  compatibility_version 1

  deny_network_access!

  def install
    if File.exist?("/tmp/dehancer-homebrew-build-for-macos13.txt")
      ENV['MACOSX_DEPLOYMENT_TARGET']="13.0"
      ohai "[dehancer] Building formula for macOS 13"
    elsif File.exist?("/tmp/dehancer-homebrew-build-for-macos15.txt")
      ENV['MACOSX_DEPLOYMENT_TARGET']="15.0"
      ohai "[dehancer] Building formula for macOS 15"
    else
      odie "[dehancer] You must specify a macOS deployment target by creating a flag file in /tmp"
    end

    if ENV['HOMEBREW_OPTFLAGS']&.include?("westmere")
      ENV['HOMEBREW_OPTFLAGS']='-march=x86-64 -arch x86_64'
      ohai "[dehancer] HOMEBREW_OPTFLAGS value changed to: #{ENV["HOMEBREW_OPTFLAGS"]}"
    end

    system "./configure", "--disable-silent-rules", "--disable-nls", "--enable-shared", "--disable-static", *std_configure_args
    system "make", "check"
    system "make", "install"

    inreplace lib/"pkgconfig/liblzma.pc", prefix, opt_prefix # dehancer
  end

  test do
    path = testpath/"data.txt"
    original_contents = "." * 1000
    path.write original_contents

    # compress: data.txt -> data.txt.xz
    system bin/"xz", path
    refute_path_exists path

    # decompress: data.txt.xz -> data.txt
    system bin/"xz", "-d", "#{path}.xz"
    assert_equal original_contents, path.read
  end
end
