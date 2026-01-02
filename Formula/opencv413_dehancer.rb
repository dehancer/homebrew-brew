class Opencv413Dehancer < Formula
  desc "Open source computer vision library"
  homepage "https://opencv.org/"
  license "Apache-2.0"

  stable do
    url "https://github.com/opencv/opencv/archive/refs/tags/4.13.0.tar.gz"
    sha256 "1d40ca017ea51c533cf9fd5cbde5b5fe7ae248291ddf2af99d4c17cf8e13017d"

    resource "contrib" do
      url "https://github.com/opencv/opencv_contrib/archive/refs/tags/4.13.0.tar.gz"
      sha256 "1e0077a4fd2960a7d2f4c9e49d6ba7bb891cac2d1be36d7e8e47aa97a9d1039b"

      livecheck do
        formula :parent
      end
    end
  end

  no_autobump! because: :requires_manual_review

  depends_on "pkgconf" => :build
  depends_on "cmake" => :build
  # depends_on "python-setuptools" => :build
  depends_on "jpeg-turbo_dehancer"
  # depends_on "jsoncpp"
  depends_on "libpng_dehancer"
  depends_on "libtiff_dehancer"
  # depends_on "numpy"
  # depends_on "openblas"
  # depends_on "openexr"
  # depends_on "openjpeg"
  # depends_on "openvino"
  # depends_on "protobuf"
  # depends_on "python@3.14"
  # depends_on "tbb"
  # depends_on "tesseract"
  # depends_on "vtk"
  depends_on "webp_dehancer"

  uses_from_macos "zlib"

  # on_macos do
  #   depends_on "glew"
  #   depends_on "imath"
  #   depends_on "libarchive"
  # end

  # def python3
  #   "python3.14"
  # end

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
      # ENV['HOMEBREW_OPTFLAGS']='-march=x86-64 -arch x86_64'
      ENV['HOMEBREW_OPTFLAGS']='-arch x86_64'
      ohai "[dehancer] HOMEBREW_OPTFLAGS value changed to: #{ENV["HOMEBREW_OPTFLAGS"]}"
    end

    resource("contrib").stage buildpath/"opencv_contrib"

    # Avoid Accelerate.framework
    # ENV["OpenBLAS_HOME"] = Formula["openblas"].opt_prefix

    # Remove bundled libraries to make sure formula dependencies are used
    libdirs = %w[libjpeg-turbo libpng libtiff libwebp]
    libdirs.each { |l| rm_r(buildpath/"3rdparty"/l) }

    args = %W[
      -DBUILD_OPENEXR=ON
      -DBUILD_SHARED_LIBS=ON
      -DBUILD_opencv_world=ON
      -DBUILD_opencv_legacy=OFF
      -DBUILD_opencv_mcc=ON
      -DWITH_JPEG=ON
      -DWITH_PNG=ON
      -DBUILD_JPEG=OFF
      -DBUILD_PNG=OFF
      -DBUILD_TIFF=OFF
      -DBUILD_WEBP=OFF
      -DBUILD_OpenCV_HAL=OFF
      -DBUILD_OPENVX=OFF
      -DOBSENSOR_USE_ORBBEC_SDK=OFF
      -DWITH_OBSENSOR=OFF
      -DWITH_FFMPEG=OFF
      -DWITH_V4L=OFF
      -DWITH_EIGEN=OFF
      -DBUILD_EXAMPLES=OFF
      -DBUILD_TESTS=OFF
      -DBUILD_PERF_TESTS=OFF
      -DVIDEOIO_ENABLE_PLUGINS=ON
      -DOPENCV_GENERATE_PKGCONFIG=ON
      -DWITH_PROTOBUF=OFF
      -DBUILD_PROTOBUF=OFF
      -DBUILD_opencv_python2=OFF
      -DBUILD_opencv_python3=OFF
      -DWITH_OPENEXR=OFF
      -DWITH_OPENJPEG=OFF
      -DBUILD_OPENJPEG=OFF
      -DWITH_JASPER=OFF
      -DBUILD_JASPER=OFF
      -DWITH_WEBP=ON
      -DBUILD_TBB=ON
      -DBUILD_ZLIB=OFF
      -DBUILD_opencv_hdf=OFF
      -DBUILD_opencv_java=OFF
      -DBUILD_opencv_text=OFF
      -DOPENCV_ENABLE_NONFREE=ON
      -DCMAKE_OSX_DEPLOYMENT_TARGET=#{ENV['MACOSX_DEPLOYMENT_TARGET']}
      -DOPENCV_EXTRA_MODULES_PATH=#{buildpath}/opencv_contrib/modules
      -DPROTOBUF_UPDATE_FILES=ON
      -DWITH_1394=OFF
      -DWITH_CUDA=OFF
      -DWITH_GPHOTO2=OFF
      -DWITH_GSTREAMER=OFF
      -DWITH_OPENGL=OFF
      -DWITH_QT=OFF
    ]

    # Ref: https://github.com/opencv/opencv/wiki/CPU-optimizations-build-options
    ENV.runtime_cpu_detection
    if Hardware::CPU.intel? && build.bottle?
      cpu_baseline = if OS.mac? && MacOS.version.requires_sse42?
        "SSE4_2"
      else
        "SSSE3"
      end
      args += %W[-DCPU_BASELINE=#{cpu_baseline} -DCPU_BASELINE_REQUIRE=#{cpu_baseline}]
    end

    system "cmake", "-S", ".", "-B", "build_shared", *args, *std_cmake_args
    inreplace "build_shared/modules/world/version_string.inc", "#{Superenv.shims_path}/", ""
    system "cmake", "--build", "build_shared"
    system "cmake", "--install", "build_shared"
    # lib.install buildpath.glob("build_shared/{lib,3rdparty/**}/*.a")

    # Prevent dependents from using fragile Cellar paths
    inreplace lib/"pkgconfig/opencv#{version.major}.pc", prefix, opt_prefix
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <opencv2/core.hpp>
      #include <opencv2/imgcodecs.hpp>
      #include <opencv2/opencv.hpp>
      #include <iostream>
      int main() {
        std::cout << CV_VERSION << std::endl;
        cv::Mat img = cv::imread("#{test_fixtures("test.jpg")}", cv::IMREAD_COLOR);
        if (img.empty()) {
          std::cerr << "Could not read test.jpg fixture" << std::endl;
          return 1;
        }
        return 0;
      }
    CPP
    system ENV.cxx, "-std=c++17", "test.cpp", "-I#{include}/opencv4", "-o", "test",
                    "-L#{lib}", "-lopencv_core", "-lopencv_imgcodecs"
    assert_equal version.to_s, shell_output("./test").strip

    # The test below seems to time out on Intel macOS.
    return if OS.mac? && Hardware::CPU.intel?

    output = shell_output("#{python3} -c 'import cv2; print(cv2.__version__)'")
    assert_equal version.to_s, output.chomp
  end
end
