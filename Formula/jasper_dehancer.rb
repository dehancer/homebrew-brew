class JasperDehancer < Formula
  desc "Library for manipulating JPEG-2000 images"
  homepage "https://ece.engr.uvic.ca/~frodo/jasper/"
  url "https://github.com/jasper-software/jasper/releases/download/version-4.2.8/jasper-4.2.8.tar.gz"
  sha256 "98058a94fbff57ec6e31dcaec37290589de0ba6f47c966f92654681a56c71fae"
  license "JasPer-2.0"

  livecheck do
    url :stable
    regex(/^version[._-]v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on "cmake" => :build
  depends_on "jpeg-turbo_dehancer"

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

    args = %w[
      -DJAS_ENABLE_DOC=OFF
      -DJAS_ENABLE_AUTOMATIC_DEPENDENCIES=OFF
    ]

    # Make sure macOS's GLUT.framework is used, not XQuartz or freeglut
    # Reported to CMake upstream 4 Apr 2016 https://gitlab.kitware.com/cmake/cmake/issues/16045
    glut_lib = "#{MacOS.sdk_path}/System/Library/Frameworks/GLUT.framework"
    "-DGLUT_glut_LIBRARY=#{glut_lib}"

    # Build in the parent of `buildpath` to avoid errors from upstream's in-source build detection.
    system "cmake", "-S", ".", "-B", "../build-shared", "-DJAS_ENABLE_SHARED=ON", *args, *std_cmake_args
    system "cmake", "--build", "../build-shared"
    system "cmake", "--install", "../build-shared"

    # Move the build directories into `buildpath` so Homebrew captures log files properly.
    buildpath.install ["../build-shared"]

    # Avoid rebuilding dependents that hard-code the prefix.
    inreplace lib/"pkgconfig/jasper.pc", prefix, opt_prefix
  end

  test do
    system bin/"jasper", "--input", test_fixtures("test.jpg"),
                         "--output", "test.bmp"
    assert_path_exists testpath/"test.bmp"
  end
end
