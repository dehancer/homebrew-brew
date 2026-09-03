# https://github.com/Homebrew/homebrew-core/commits/main/Formula/o/openjpeg.rb
# 1a600a512e71e4c076344e68f27c9472b1dd615d

class OpenjpegDehancer < Formula
  desc "Library for JPEG-2000 image manipulation"
  homepage "https://www.openjpeg.org/"
  url "https://github.com/uclouvain/openjpeg/archive/refs/tags/v2.5.4.tar.gz"
  sha256 "a695fbe19c0165f295a8531b1e4e855cd94d0875d2f88ec4b61080677e27188a"
  license "BSD-2-Clause"
  compatibility_version 1
  head "https://github.com/uclouvain/openjpeg.git", branch: "master"

  depends_on "cmake" => :build
  # depends_on "doxygen" => :build # dehancer
  depends_on "libpng_dehancer"
  depends_on "libtiff_dehancer"
  depends_on "little-cms2_dehancer"

  def install
    if ENV['HOMEBREW_OPTFLAGS']&.include?("westmere")
      ENV['HOMEBREW_OPTFLAGS']='-march=x86-64 -arch x86_64'
      ohai "[dehancer] HOMEBREW_OPTFLAGS value changed to: #{ENV["HOMEBREW_OPTFLAGS"]}"
    end

    system "cmake", "-S", ".", "-B", "build", *std_cmake_args,
                    "-DCMAKE_INSTALL_RPATH=#{rpath}",
                    "-DBUILD_DOC=OFF"
    # BUILD_DOC=OFF changed by Dehancer
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <openjpeg.h>

      int main () {
        opj_image_cmptparm_t cmptparm;
        const OPJ_COLOR_SPACE color_space = OPJ_CLRSPC_GRAY;

        opj_image_t *image;
        image = opj_image_create(1, &cmptparm, color_space);

        opj_image_destroy(image);
        return 0;
      }
    C
    system ENV.cc, "-I#{include.children.first}",
           testpath/"test.c", "-L#{lib}", "-lopenjp2", "-o", "test"
    system "./test"
  end
end
