class WebpDehancer < Formula
  desc "Image format providing lossless and lossy compression for web images"
  homepage "https://developers.google.com/speed/webp/"
  url "https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-1.6.0.tar.gz"
  sha256 "e4ab7009bf0629fd11982d4c2aa83964cf244cffba7347ecd39019a9e38c4564"
  license "BSD-3-Clause"
  head "https://chromium.googlesource.com/webm/libwebp.git", branch: "main"

  livecheck do
    url "https://developers.google.com/speed/webp/docs/compiling"
    regex(/libwebp[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  depends_on "cmake" => :build
  depends_on "giflib_dehancer"
  depends_on "jpeg-turbo_dehancer"
  depends_on "libpng_dehancer"
  depends_on "libtiff_dehancer"

  def install
    args = %W[
      -DCMAKE_INSTALL_RPATH=#{rpath}
    ]
    system "cmake", "-S", ".", "-B", "static", *std_cmake_args, "-DBUILD_SHARED_LIBS=OFF",
      "-DWEBP_BUILD_ANIM_UTILS=OFF",
      "-DWEBP_BUILD_CWEBP=OFF",
      "-DWEBP_BUILD_DWEBP=OFF",
      "-DWEBP_BUILD_GIF2WEBP=OFF",
      "-DWEBP_BUILD_IMG2WEBP=OFF",
      "-DWEBP_BUILD_VWEBP=OFF",
      "-DWEBP_BUILD_WEBPINFO=OFF",
      "-DWEBP_BUILD_WEBPMUX=OFF",
      *args
    system "cmake", "--build", "static"
    lib.install buildpath.glob("static/*.a")
  end

  test do
  end
end
