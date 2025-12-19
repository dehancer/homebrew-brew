class LibtiffDehancer < Formula
  desc "TIFF library and utilities"
  homepage "https://libtiff.gitlab.io/libtiff/"
  url "https://download.osgeo.org/libtiff/tiff-4.7.1.tar.gz"
  mirror "https://fossies.org/linux/misc/tiff-4.7.1.tar.gz"
  sha256 "f698d94f3103da8ca7438d84e0344e453fe0ba3b7486e04c5bf7a9a3fabe9b69"
  license "libtiff"

  livecheck do
    url "https://download.osgeo.org/libtiff/"
    regex(/href=.*?tiff[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  option "with-macos13", "Build for macOS 13.0"
  option "with-macos15", "Build for macOS 15"

  depends_on "jpeg-turbo_dehancer"
  depends_on "xz_dehancer"
  depends_on "zstd_dehancer"
  uses_from_macos "zlib"

  def install
    if build.with? "macos13"
      ENV['MACOSX_DEPLOYMENT_TARGET']="13.0"
    elsif build.with? "macos15"
      ENV['MACOSX_DEPLOYMENT_TARGET']="15.0"
    else
      odie "You must specify a macOS deployment target option: --with-macos13 or --with-macos15"
    end

    if ENV['HOMEBREW_OPTFLAGS']&.include?("westmere")
      ENV['HOMEBREW_OPTFLAGS']='-march=x86-64 -arch x86_64'
      ohai "HOMEBREW_OPTFLAGS value changed to: #{ENV["HOMEBREW_OPTFLAGS"]}"
    end

    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-libdeflate
      --disable-webp
      --enable-zstd
      --enable-lzma
      --with-jpeg-include-dir=#{Formula["jpeg-turbo"].opt_include}
      --with-jpeg-lib-dir=#{Formula["jpeg-turbo"].opt_lib}
      --without-x
    ]
    system "./configure", *args
    system "make", "install"

    # Avoid rebuilding dependents that hard-code the prefix.
    inreplace lib/"pkgconfig/libtiff-4.pc", prefix, opt_prefix
  end

  test do
    (testpath/"test.c").write <<~C
      #include <tiffio.h>

      int main(int argc, char* argv[])
      {
        TIFF *out = TIFFOpen(argv[1], "w");
        TIFFSetField(out, TIFFTAG_IMAGEWIDTH, (uint32) 10);
        TIFFClose(out);
        return 0;
      }
    C
    system ENV.cc, "test.c", "-L#{lib}", "-ltiff", "-o", "test"
    system "./test", "test.tif"
    assert_match(/ImageWidth.*10/, shell_output("#{bin}/tiffdump test.tif"))
  end
end
