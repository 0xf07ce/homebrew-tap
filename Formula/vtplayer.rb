class Vtplayer < Formula
  desc "Terminal-based music player for MP3, OGG, FLAC, and WAV"
  homepage "https://github.com/0xf07ce/vtplayer"
  url "https://github.com/0xf07ce/vtplayer/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "0b624d34f272c7f6d892c0cd0d948365fd5e2d90949eddc765cf2332f47778b8"
  license "LGPL-2.1-or-later"

  depends_on "cmake" => :build
  # ventty (pinned to v0.2.0) and cxxopts are fetched via CMake FetchContent
  # during the build; no separate Homebrew dependency is required.

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    bin.install "build/vtplayer"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/vtplayer --version")
  end
end
