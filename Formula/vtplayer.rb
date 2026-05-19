class Vtplayer < Formula
  desc "Terminal-based music player for MP3, OGG, FLAC, and WAV"
  homepage "https://github.com/0xf07ce/vtplayer"
  url "https://github.com/0xf07ce/vtplayer/archive/refs/tags/v0.7.2.tar.gz"
  sha256 "9b66380f2a6a9e8a6321ffc742ad7cc46413f11820e6d1d46567e98d17aed017"
  license "LGPL-2.1-or-later"

  # The `bottle do` block is written automatically by the release workflow
  # (`brew bottle --merge --write`); do not edit it by hand.
  bottle do
    root_url "https://github.com/0xf07ce/vtplayer/releases/download/v0.7.2"
    sha256 cellar: :any, arm64_tahoe:   "ec7984cfa5303ab62b434d968df866f9bd47b09acbf8555df1b40875e49b3efb"
    sha256 cellar: :any, arm64_sequoia: "da1f5d2aeb0edd8c382f4e4ff7aa3b87a23bbb92d6213196480aa051c06a59a0"
  end

  depends_on "cmake" => :build

  # Previously git-cloned by CMake FetchContent and built from source on every
  # bottle. Now taken from prebuilt Homebrew bottles via
  # -DVTPLAYER_USE_SYSTEM_DEPS=ON (find_package). This removes the TagLib
  # source build and per-dependency resource sha256 churn.
  depends_on "cxxopts"
  depends_on "sqlite"
  depends_on "taglib"

  # ventty has no upstream install()/export() rules, so it cannot be a
  # find_package dependency. It is small and tagged infrequently, so it stays
  # staged as a resource and fed to CMake via FETCHCONTENT_SOURCE_DIR_VENTTY
  # (no network during the build). This resource's sha256 is bumped
  # automatically by the release workflow's `prepare` job.
  resource "ventty" do
    url "https://github.com/0xf07ce/ventty/archive/refs/tags/v0.2.1.tar.gz"
    sha256 "1d93b527b358bf0bcd3c2515b60de860d60598c1983c7b5a8fefe4e83f9aad98"
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
