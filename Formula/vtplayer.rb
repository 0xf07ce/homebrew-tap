class Vtplayer < Formula
  desc "Terminal-based music player for MP3, OGG, FLAC, and WAV"
  homepage "https://github.com/0xf07ce/vtplayer"
  url "https://github.com/0xf07ce/vtplayer/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "06fae90e788d355774be7b9bb28ff9d4b9cb9b82f777010876f80500a27945d5"
  license "LGPL-2.1-or-later"

  bottle do
    root_url "https://github.com/0xf07ce/vtplayer/releases/download/v0.4.0"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "0a09f22c6b17b981e2ac3a2df957b0d5ae640c9a552d64e48e6595c3d75005b3"
    sha256 cellar: :any_skip_relocation, arm64_tahoe: "bb5d2a41b50f146001dfb5e1023f09bf34b28756a4792a88507e9a90482fc8ea"
  end

  depends_on "cmake" => :build
  # TagLib 2.x requires utfcpp headers at compile time; taglib is linked
  # statically into vtplayer, so this is build-only.
  depends_on "utf8cpp" => :build

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

  resource "taglib" do
    url "https://github.com/taglib/taglib/archive/refs/tags/v2.0.2.tar.gz"
    sha256 "0de288d7fe34ba133199fd8512f19cc1100196826eafcb67a33b224ec3a59737"
  end

  def install
    ventty_src  = buildpath/"_deps/ventty"
    cxxopts_src = buildpath/"_deps/cxxopts"
    taglib_src  = buildpath/"_deps/taglib"
    resource("ventty").stage  ventty_src
    resource("cxxopts").stage cxxopts_src
    resource("taglib").stage  taglib_src

    system "cmake", "-S", ".", "-B", "build", *std_cmake_args,
                    "-DFETCHCONTENT_SOURCE_DIR_VENTTY=#{ventty_src}",
                    "-DFETCHCONTENT_SOURCE_DIR_CXXOPTS=#{cxxopts_src}",
                    "-DFETCHCONTENT_SOURCE_DIR_TAGLIB=#{taglib_src}"
    system "cmake", "--build", "build"
    bin.install "build/vtplayer"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/vtplayer --version")
  end
end
