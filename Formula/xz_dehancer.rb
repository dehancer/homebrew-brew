# https://github.com/Homebrew/homebrew-core/blob/1a7068e60ea054dbea40754549081bc0d38013ac/Formula/x/xz.rb
class XzDehancer < Formula
  desc "General-purpose data compression with high compression ratio"
  homepage "https://tukaani.org/xz/"
  url "https://github.com/tukaani-project/xz/releases/download/v5.8.2/xz-5.8.2.tar.gz"
  mirror "https://downloads.sourceforge.net/project/lzmautils/xz-5.8.2.tar.gz"
  mirror "http://downloads.sourceforge.net/project/lzmautils/xz-5.8.2.tar.gz"
  sha256 "ce09c50a5962786b83e5da389c90dd2c15ecd0980a258dd01f70f9e7ce58a8f1"
  license all_of: [
    "0BSD",
    "GPL-2.0-or-later",
  ]
  version_scheme 1

  deny_network_access! [:build, :postinstall]

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

    system "./configure", *std_configure_args, "--disable-silent-rules", "--disable-nls", "--enable-shared", "--disable-static"
    system "make", "check"
    system "make", "install"
    inreplace lib/"pkgconfig/liblzma.pc", prefix, opt_prefix
  end

  test do
  end
end
