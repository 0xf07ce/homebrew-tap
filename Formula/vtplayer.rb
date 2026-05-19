class Vtplayer < Formula
  desc "Terminal-based music player for MP3, OGG, FLAC, and WAV"
  homepage "https://github.com/0xf07ce/vtplayer"
  url "https://github.com/0xf07ce/vtplayer/archive/refs/tags/v0.7.1.tar.gz"
  sha256 "2537b101a702b55ef1d2b907d741ec6d433716bb7d255216069780b213738ba5"
  license "LGPL-2.1-or-later"

  # The `bottle do` block is written automatically by the release workflow
  # (`brew bottle --merge --write`); do not edit it by hand.
  bottle do
    root_url "https://github.com/0xf07ce/vtplayer/releases/download/v0.7.1"
    sha256 cellar: :any, arm64_tahoe:   "b8c4443a74bd4f6b835f266692320edc6bdbb40de97c9d486139d6b47e5457c8"
    sha256 cellar: :any, arm64_sequoia: "a6e87c655e96ecf99404620840ec26b54acc3b88fb39be1917c876d4db16e6fd"
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
