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

  no_autobump! because: :requires_manual_review

  def install
    ENV['MACOSX_DEPLOYMENT_TARGET']="13.0"

    ENV['HOMEBREW_OPTFLAGS'] = ENV['HOMEBREW_OPTFLAGS'].gsub("westmere", "x86-64") if ENV['HOMEBREW_OPTFLAGS']
    ENV['HOMEBREW_RUSTFLAGS'] = ENV['HOMEBREW_RUSTFLAGS'].gsub("westmere", "x86-64") if ENV['HOMEBREW_RUSTFLAGS']

    ohai "HOMEBREW_OPTFLAGS value: #{ENV["HOMEBREW_OPTFLAGS"]}"
    ohai "HOMEBREW_RUSTFLAGS value: #{ENV["HOMEBREW_RUSTFLAGS"]}"

    system "make", "all"
    system "make", "install", "PREFIX=#{prefix}"
    rm_f Dir[lib/"libgif*.dylib"]
  end

  test do
    output = shell_output("#{bin}/giftext #{test_fixtures("test.gif")}")
    assert_match "Screen Size - Width = 1, Height = 1", output
  end
end
