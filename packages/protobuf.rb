# Adapted from Arch Linux protobuf PKGBUILD at:
# https://github.com/archlinux/svntogit-packages/raw/packages/protobuf/trunk/PKGBUILD

require 'package'

class Protobuf < Package
  description 'Protocol Buffers - Googles data interchange format'
  homepage 'https://protobuf.dev'
  version '21.12'
  license 'BSD'
  compatibility 'all'
  source_url "https://github.com/protocolbuffers/protobuf/archive/v#{version}/protobuf-#{version}.tar.gz"
  source_sha256 '22fdaf641b31655d4b2297f9981fa5203b2866f8332d3c6333f6b0107bb320de'
  binary_compression 'tar.zst'

  binary_sha256({
    aarch64: '525fa6ba3fe024ceadab14380e4bd9e2b4a7e4c2e486285cf0cc2483a541b581',
     armv7l: '525fa6ba3fe024ceadab14380e4bd9e2b4a7e4c2e486285cf0cc2483a541b581',
       i686: '4dedac0a666c3050f7e4944bab9aa2c676a727fd448bbf6ae37cc1494ac13e5c',
     x86_64: '314c9575d0a48a7a4ccada06404594452ab99183409aaec9e53abd8d1ede0dfe'
  })

  depends_on 'gcc_lib' # R
  depends_on 'glibc' # R
  depends_on 'zlibpkg' # R

  def self.build
    FileUtils.mkdir('builddir')
    Dir.chdir('builddir') do
      system "cmake #{CREW_CMAKE_OPTIONS} \
      -Dprotobuf_BUILD_SHARED_LIBS=ON \
      -Dprotobuf_BUILD_TESTS=OFF \
      ../ -G Ninja"
    end
    system 'samu -C builddir'
  end

  def self.install
    system "DESTDIR=#{CREW_DEST_DIR} samu -C builddir install"
  end
end
