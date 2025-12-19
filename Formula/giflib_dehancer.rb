class GiflibDehancer < Formula
  desc "Library and utilities for processing GIFs"
  homepage "https://giflib.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/giflib/giflib-5.2.2.tar.gz"
  sha256 "be7ffbd057cadebe2aa144542fd90c6838c6a083b5e8a9048b8ee3b66b29d5fb"
  license "MIT"

  livecheck do
    url :stable
    regex(%r{url=.*?/giflib[._-]v?(\d+(?:\.\d+)+)\.t}i)
  end

  option "with-13.0", "Build for macOS 13.0"
  option "with-15", "Build for macOS 15"

  no_autobump! because: :requires_manual_review

  def install
    if build.with? "macos-13.0"
      ENV['MACOSX_DEPLOYMENT_TARGET']="13.0"
    elsif build.with? "macos-15"
      ENV['MACOSX_DEPLOYMENT_TARGET']="15.0"
    else
      odie "You must specify a macOS deployment target option: --with-13.0 or --with-15"
    end

    if ENV['HOMEBREW_OPTFLAGS']&.include?("westmere")
      ENV['HOMEBREW_OPTFLAGS']='-march=x86-64 -arch x86_64'
      ohai "HOMEBREW_OPTFLAGS value changed to: #{ENV["HOMEBREW_OPTFLAGS"]}"
    end

    # HOMEBREW_RUSTFLAGS

    system "make", "all"
    system "make", "install", "PREFIX=#{prefix}"
    rm_f Dir[lib/"libgif*.dylib"]
  end

  test do
    output = shell_output("#{bin}/giftext #{test_fixtures("test.gif")}")
    assert_match "Screen Size - Width = 1, Height = 1", output
  end
end
