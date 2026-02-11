# https://github.com/Homebrew/homebrew-core/blob/1f06fff/Formula/e/exiv2.rb
class Exiv2Dehancer < Formula
  desc "EXIF and IPTC metadata manipulation library and tools"
  homepage "https://exiv2.org/"
  url "https://github.com/Exiv2/exiv2/archive/refs/tags/v0.28.7.tar.gz"
  sha256 "5e292b02614dbc0cee40fe1116db2f42f63ef6b2ba430c77b614e17b8d61a638"
  license "GPL-2.0-or-later"
  head "https://github.com/Exiv2/exiv2.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on "cmake" => :build
  depends_on "brotli_dehancer"

  uses_from_macos "curl"
  uses_from_macos "expat"
  uses_from_macos "zlib"

  on_macos do
    depends_on "gettext"
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
      -DEXIV2_ENABLE_BROTLI=ON
      -DEXIV2_ENABLE_INIH=OFF
      -DEXIV2_BUILD_SAMPLES=OFF
      -DEXIV2_BUILD_EXIV2_COMMAND=OFF
      -DEXIV2_ENABLE_XMP=ON
      -DEXIV2_ENABLE_DYNAMIC_RUNTIME=OFF
      -DEXIV2_ENABLE_FILESYSTEM_ACCESS=ON
      -DEXIV2_BUILD_UNIT_TESTS=OFF
      -DEXIV2_BUILD_DOC=OFF
      -DCMAKE_INSTALL_NAME_DIR:STRING=#{lib}
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    inreplace lib/"pkgconfig/exiv2.pc", prefix, opt_prefix
  end

  test do
  end
end
