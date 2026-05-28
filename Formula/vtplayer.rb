class Vtplayer < Formula
  desc "Terminal-based music player for MP3, OGG, FLAC, and WAV"
  homepage "https://github.com/0xf07ce/vtplayer"
  url "https://github.com/0xf07ce/vtplayer/archive/refs/tags/v0.13.3.tar.gz"
  sha256 "09fbe38d3467891aba3b130304d4785be4af965e936a3a32073b8222caf8cf4f"
  license "LGPL-2.1-or-later"

  # The `bottle do` block is written automatically by the release workflow
  # (`brew bottle --merge --write`); do not edit it by hand.
  bottle do
    root_url "https://github.com/0xf07ce/vtplayer/releases/download/v0.13.3"
    sha256 cellar: :any, arm64_tahoe:   "ca5fd62423c9b2113720264bcdcea5b6f244aee4c00d32abcb0731915652dca9"
    sha256 cellar: :any, arm64_sequoia: "dab2557b24fd8429d33b59cd7f4292f8b219aed83d1ea335c0c8d70bbb5d82af"
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  # Previously git-cloned by CMake FetchContent and built from source on every
  # bottle. Now taken from prebuilt Homebrew bottles via
  # -DVTPLAYER_USE_SYSTEM_DEPS=ON (find_package). This removes the TagLib
  # source build and per-dependency resource sha256 churn.
  depends_on "cxxopts"
  depends_on "sqlite"
  depends_on "taglib"

  # ffmpeg is required at both build (libav headers + pkg-config) and runtime
  # (linked shared libraries). vtplayer delegates *all* audio decoding —
  # local files and internet-radio streams — to libavformat/libavcodec/
  # libswresample, so the formerly optional runtime `ffmpeg` binary
  # dependency has been replaced with a mandatory library-level link.
  depends_on "ffmpeg"

  # ventty has no upstream install()/export() rules, so it cannot be a
  # find_package dependency. It is small and tagged infrequently, so it stays
  # staged as a resource and fed to CMake via FETCHCONTENT_SOURCE_DIR_VENTTY
  # (no network during the build). This resource's sha256 is bumped
  # automatically by the release workflow's `prepare` job.
  resource "ventty" do
    url "https://github.com/0xf07ce/ventty/archive/refs/tags/v0.3.1.tar.gz"
    sha256 "4259c6768f443b0bd6bc64ed06e7fe28784cbd2b7c965f1eff05ab8b37bbd449"
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
