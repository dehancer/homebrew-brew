# https://github.com/Homebrew/homebrew-core/blob/af47bed/Formula/lib/libpng.rb
class LibpngDehancer < Formula
  desc "Library for manipulating PNG images"
  homepage "https://www.libpng.org/pub/png/libpng.html"
  url "https://downloads.sourceforge.net/project/libpng/libpng16/1.6.55/libpng-1.6.55.tar.xz"
  mirror "https://sourceforge.mirrorservice.org/l/li/libpng/libpng16/1.6.55/libpng-1.6.55.tar.xz"
  sha256 "d925722864837ad5ae2a82070d4b2e0603dc72af44bd457c3962298258b8e82d"
  license "libpng-2.0"

  livecheck do
    url :stable
    regex(%r{url=.*?/libpng[._-]v?(\d+(?:\.\d+)+)\.t}i)
  end

  head do
    url "https://github.com/glennrp/libpng.git", branch: "libpng16"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  uses_from_macos "zlib"

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

    system "./configure", "--enable-shared", "--disable-static", "--disable-silent-rules", *std_configure_args
    system "make"
    system "make", "test"
    system "make", "install"

    # Avoid rebuilds of dependants that hardcode this path.
    inreplace [ lib/"pkgconfig/libpng.pc", lib/"pkgconfig/libpng16.pc"], prefix, opt_prefix
  end

  test do
    (testpath/"test.c").write <<~C
      #include <png.h>

      int main(void)
      {
        png_structp png_ptr;
        png_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
        png_destroy_write_struct(&png_ptr, (png_infopp)NULL);
        return 0;
      }
    C
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lpng", "-o", "test"
    system "./test"
  end
end
