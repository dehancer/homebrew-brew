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

  # Move logo resizing to be a prereq for giflib website only, so that imagemagick is not required to build package
  # Remove this patch once the upstream fix is released:
  # https://sourceforge.net/p/giflib/code/ci/d54b45b0240d455bbaedee4be5203d2703e59967/
  patch :DATA

  def install
    ENV['MACOSX_DEPLOYMENT_TARGET']="13.0"
    system "make", "all"
    system "make", "install", "PREFIX=#{prefix}"
    system "rm", "-f", "#{prefix}/lib/libgif*dylib"
  end

  test do
    output = shell_output("#{bin}/giftext #{test_fixtures("test.gif")}")
    assert_match "Screen Size - Width = 1, Height = 1", output
  end
end
