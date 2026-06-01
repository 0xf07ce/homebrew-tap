class Vtplayer < Formula
  desc "Terminal-based music player for MP3, OGG, FLAC, and WAV"
  homepage "https://github.com/0xf07ce/vtplayer"
  url "https://github.com/0xf07ce/vtplayer/archive/refs/tags/v0.15.0.tar.gz"
  sha256 "7277bde6933f3a69020bd060cd6d8f018c6f3e771509659a81ac98b77c937789"
  license "LGPL-2.1-or-later"

  # The `bottle do` block is written automatically by the release workflow
  # (`brew bottle --merge --write`); do not edit it by hand.
  bottle do
    root_url "https://github.com/0xf07ce/vtplayer/releases/download/v0.15.0"
    sha256 cellar: :any, arm64_tahoe:   "aa80de8fcb11a1fb16471b591410a762b68451ec0414d8ccbe7a2a8240fa030e"
    sha256 cellar: :any, arm64_sequoia: "5d688aa44ac11d300dee650426792b0b516f41d7d7b9a848ea9a40dc564f1b00"
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
