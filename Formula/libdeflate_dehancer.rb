class LibdeflateDehancer < Formula
  desc "Heavily optimized DEFLATE/zlib/gzip compression and decompression"
  homepage "https://github.com/ebiggers/libdeflate"
  url "https://github.com/ebiggers/libdeflate/archive/refs/tags/v1.25.tar.gz"
  sha256 "d11473c1ad4c57d874695e8026865e38b47116bbcb872bfc622ec8f37a86017d"
  license "MIT"

  depends_on "cmake" => :build

  def install
    ENV['MACOSX_DEPLOYMENT_TARGET']="13.0"
    ENV['HOMEBREW_OPTFLAGS']=""
    ENV['HOMEBREW_RUSTFLAGS']=""

    system "cmake", "-S", ".", "-B", "build", "-DLIBDEFLATE_BUILD_SHARED_LIB=OFF", "-DLIBDEFLATE_BUILD_STATIC_LIB=ON", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
    inreplace lib/"pkgconfig/libdeflate.pc", prefix, opt_prefix
  end

  test do
    (testpath/"foo").write "test"
    system bin/"libdeflate-gzip", "foo"
    system bin/"libdeflate-gunzip", "-d", "foo.gz"
    assert_equal "test", (testpath/"foo").read
  end
end
