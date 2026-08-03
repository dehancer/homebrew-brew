# https://github.com/Homebrew/homebrew-core/commits/main/Formula/e/exiv2.rb
# 77822dd9854e69c9e7a0786a7d293c404c93b989

class Exiv2Dehancer < Formula
  desc "EXIF and IPTC metadata manipulation library and tools"
  homepage "https://exiv2.org/"
  url "https://github.com/Exiv2/exiv2/archive/refs/tags/v0.28.8.tar.gz"
  sha256 "ea51b0609f58a9afa063b60daa1539948b62247721e154f4fff0ad3aec9f9756"
  license "GPL-2.0-or-later"
  compatibility_version 1
  head "https://github.com/Exiv2/exiv2.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on "cmake" => :build
  depends_on "gettext" => :build # for msgmerge
  depends_on "brotli_dehancer"

  uses_from_macos "curl"
  uses_from_macos "expat"

  on_macos do
    depends_on "gettext"
  end

  on_linux do
    depends_on "zlib-ng-compat"
  end

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

    args = %W[
      -DEXIV2_ENABLE_XMP=ON
      -DEXIV2_ENABLE_VIDEO=OFF
      -DEXIV2_ENABLE_PNG=ON
      -DEXIV2_ENABLE_NLS=ON
      -DEXIV2_ENABLE_PRINTUCS2=ON
      -DEXIV2_ENABLE_LENSDATA=ON
      -DEXIV2_ENABLE_WEBREADY=OFF
      -DEXIV2_ENABLE_CURL=OFF
      -DEXIV2_ENABLE_SSH=OFF
      -DEXIV2_BUILD_SAMPLES=OFF
      -DCMAKE_INSTALL_NAME_DIR:STRING=#{lib}
      -DEXIV2_ENABLE_INIH=OFF
      -DEXIV2_ENABLE_DYNAMIC_RUNTIME=OFF
      -DEXIV2_ENABLE_FILESYSTEM_ACCESS=ON
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    inreplace lib/"pkgconfig/exiv2.pc", prefix, opt_prefix # dehancer
  end

  test do
    assert_match "288 Bytes", shell_output("#{bin}/exiv2 #{test_fixtures("test.jpg")}", 253)
  end
end
