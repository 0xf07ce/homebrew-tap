class Vtplayer < Formula
  desc "Terminal-based music player for MP3, OGG, FLAC, and WAV"
  homepage "https://github.com/0xf07ce/vtplayer"
  url "https://github.com/0xf07ce/vtplayer/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "3c1d87be45cbf5c87656005655877dfb25e141c3c115dbfc7500d8e7a53ec267"
  license "LGPL-2.1-or-later"

  depends_on "cmake" => :build

  # vtplayer's CMakeLists.txt pulls these via FetchContent. Homebrew blocks
  # in-build FetchContent, so we stage them as resources and point CMake at
  # the staged source via FETCHCONTENT_SOURCE_DIR_<NAME>.
  resource "ventty" do
    url "https://github.com/0xf07ce/ventty/archive/refs/tags/v0.2.0.tar.gz"
    sha256 "960fa4f8305b3b3bed3f7ae4bb74081c48ebe3448df1eb842462fadd6666a782"
  end

  resource "cxxopts" do
    url "https://github.com/jarro2783/cxxopts/archive/refs/tags/v3.2.1.tar.gz"
    sha256 "841f49f2e045b9c6365997c2a8fbf76e6f215042dda4511a5bb04bc5ebc7f88a"
  end

  def install
    ventty_src  = buildpath/"_deps/ventty"
    cxxopts_src = buildpath/"_deps/cxxopts"
    resource("ventty").stage  ventty_src
    resource("cxxopts").stage cxxopts_src

    system "cmake", "-S", ".", "-B", "build", *std_cmake_args,
                    "-DFETCHCONTENT_SOURCE_DIR_VENTTY=#{ventty_src}",
                    "-DFETCHCONTENT_SOURCE_DIR_CXXOPTS=#{cxxopts_src}"
    system "cmake", "--build", "build"
    bin.install "build/vtplayer"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/vtplayer --version")
  end
end
