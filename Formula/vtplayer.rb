class Vtplayer < Formula
  desc "Terminal-based music player for MP3, OGG, FLAC, and WAV"
  homepage "https://github.com/0xf07ce/vtplayer"
  url "https://github.com/0xf07ce/vtplayer/archive/refs/tags/v1.0.2.tar.gz"
  sha256 "d04a77ddcea41bc57e34c498024e99a05e735769926b9789c260fbae6c355ce5"
  license "LGPL-2.1-or-later"

  # The `bottle do` block is written automatically by the release workflow
  # (`brew bottle --merge --write`); do not edit it by hand.
  bottle do
    root_url "https://github.com/0xf07ce/vtplayer/releases/download/v1.0.2"
    sha256 cellar: :any, arm64_tahoe:   "c6b3d406f7029e4603f91b6cf35259f1d2a55bea52abdd090b50f4291f71e678"
    sha256 cellar: :any, arm64_sequoia: "dcf18908a21201e1311375b12ca613c3dbfbebe0dfc5dbbb352da544824b5b74"
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  # ffmpeg is required at both build (libav headers + pkg-config) and runtime
  # (linked shared libraries). vtplayer delegates *all* audio decoding —
  # local files and internet-radio streams — to libavformat/libavcodec/
  # libswresample, so the formerly optional runtime `ffmpeg` binary
  # dependency has been replaced with a mandatory library-level link.
  depends_on "ffmpeg"

  # Previously git-cloned by CMake FetchContent and built from source on every
  # bottle. Now taken from prebuilt Homebrew bottles via
  # -DVTPLAYER_USE_SYSTEM_DEPS=ON (find_package). This removes the TagLib
  # source build and per-dependency resource sha256 churn. cxxopts is no
  # longer listed: it is vendored as a single header in deps/include/cxxopts/.
  depends_on "sqlite"
  depends_on "taglib"

  # ventty has no upstream install()/export() rules, so it cannot be a
  # find_package dependency. It is small and tagged infrequently, so it stays
  # staged as a resource and fed to CMake via FETCHCONTENT_SOURCE_DIR_VENTTY
  # (no network during the build). This resource's sha256 is bumped
  # automatically by the release workflow's `prepare` job.
  resource "ventty" do
    url "https://github.com/0xf07ce/ventty/archive/refs/tags/v0.4.1.tar.gz"
    sha256 "64b51518da2c4850f7b82525167ef3d366f9b2902a16b0095861c14aea397808"
  end

  def install
    ventty_src = buildpath/"_deps/ventty"
    resource("ventty").stage ventty_src

    system "cmake", "-S", ".", "-B", "build", *std_cmake_args,
           "-DVTPLAYER_USE_SYSTEM_DEPS=ON",
           "-DFETCHCONTENT_SOURCE_DIR_VENTTY=#{ventty_src}"
    system "cmake", "--build", "build"
    bin.install "build/vtplayer"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/vtplayer --version")
  end
end
