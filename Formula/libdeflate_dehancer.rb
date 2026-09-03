# https://github.com/Homebrew/homebrew-core/commits/main/Formula/lib/libdeflate.rb
# 7c29703036e56bbf83ab7b0e5cee0a394e018fba

class LibdeflateDehancer < Formula
  desc "Heavily optimized DEFLATE/zlib/gzip compression and decompression"
  homepage "https://github.com/ebiggers/libdeflate"
  url "https://github.com/ebiggers/libdeflate/archive/refs/tags/v1.26.tar.gz"
  sha256 "bba03fffc5538576213675ce6968fcff6ce2e67d82e4d5febea2d05f9f13cf85"
  license "MIT"
  compatibility_version 1

  depends_on "cmake" => :build

  def install
    if ENV['HOMEBREW_OPTFLAGS']&.include?("westmere")
      ENV['HOMEBREW_OPTFLAGS']='-march=x86-64 -arch x86_64'
      ohai "[dehancer] HOMEBREW_OPTFLAGS value changed to: #{ENV["HOMEBREW_OPTFLAGS"]}"
    end

    system "cmake", "-S", ".", "-B", "build", "-DLIBDEFLATE_BUILD_SHARED_LIB=ON", "-DLIBDEFLATE_BUILD_STATIC_LIB=OFF", *std_cmake_args
    # system "cmake", "-S", ".", "-B", "build", *std_cmake_args # changed by dehancer
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    inreplace lib/"pkgconfig/libdeflate.pc", prefix, opt_prefix # dehancer
  end

  test do
    (testpath/"foo").write "test"
    system bin/"libdeflate-gzip", "foo"
    system bin/"libdeflate-gunzip", "-d", "foo.gz"
    assert_equal "test", (testpath/"foo").read
  end
end
