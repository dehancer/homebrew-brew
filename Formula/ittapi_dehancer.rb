class IttapiDehancer < Formula
  desc "Intel Instrumentation and Tracing Technology (ITT) and Just-In-Time (JIT) API"
  homepage "https://github.com/intel/ittapi"
  url "https://github.com/intel/ittapi/archive/refs/tags/v3.26.4.tar.gz"
  sha256 "22e62bc1e0bae9ca001d6ae7447d26b7bcfe5d955724d74e6bd1e3e2102b48b1"
  license "GPL-2.0-only"
  head "https://github.com/intel/ittapi.git", branch: "master"

  depends_on "cmake" => :build

  def install
    ENV['MACOSX_DEPLOYMENT_TARGET']="13.0"
    ENV['HOMEBREW_OPTFLAGS']=""
    ENV['HOMEBREW_RUSTFLAGS']=""

    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <ittnotify.h>

      __itt_domain* domain = __itt_domain_create("Example.Domain.Global");
      __itt_string_handle* handle_main = __itt_string_handle_create("main");

      int main()
      {
        __itt_task_begin(domain, __itt_null, __itt_null, handle_main);
        __itt_task_end(domain);
        return 0;
      }
    CPP
    system ENV.cxx, "test.cpp", "-o", "test",
                    "-I#{include}",
                    "-L#{lib}", "-littnotify"
    system "./test"
  end
end
