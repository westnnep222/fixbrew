require 'package'

class Python3 < Package
  description 'Python is a programming language that lets you work quickly and integrate systems more effectively.'
  homepage 'https://www.python.org/'
  version '3.12.0'
  license 'PSF-2.0'
  compatibility 'all'
  source_url "https://www.python.org/ftp/python/#{version}/Python-#{version}.tar.xz"
  source_sha256 '795c34f44df45a0e9b9710c8c71c15c671871524cd412ca14def212e8ccb155d'

  binary_url({
    aarch64: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/python3/3.12.0_armv7l/python3-3.12.0-chromeos-armv7l.tar.zst',
     armv7l: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/python3/3.12.0_armv7l/python3-3.12.0-chromeos-armv7l.tar.zst',
       i686: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/python3/3.12.0_i686/python3-3.12.0-chromeos-i686.tar.zst',
     x86_64: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/python3/3.12.0_x86_64/python3-3.12.0-chromeos-x86_64.tar.zst'
  })
  binary_sha256({
    aarch64: '1241f2fb4681b09f2c0f9d00799222b63ecc79488040403d68186bc8093eaf6c',
     armv7l: '1241f2fb4681b09f2c0f9d00799222b63ecc79488040403d68186bc8093eaf6c',
       i686: '14a2bd096da4042114904389677b9b0ba44890a970b3c65d04b1191a2035fbe6',
     x86_64: '59654b4d1746fbd04d42a42aeeae7bd4ca788bc36ff57942644ffb0d56061617'
  })

  depends_on 'autoconf_archive' => :build
  depends_on 'bzip2' # R
  depends_on 'expat' # R
  depends_on 'gcc_lib' # R
  depends_on 'gdbm' # R
  depends_on 'glibc' # R
  depends_on 'krb5' => :build
  depends_on 'libdb' # R
  depends_on 'libffi' # R
  depends_on 'libtirpc' => :build
  depends_on 'mpdecimal' # R
  depends_on 'ncurses' # R
  depends_on 'openssl' # R
  depends_on 'readline' # R
  depends_on 'sqlite' # R
  depends_on 'tcl' => :build unless ARCH == 'i686' # Needed for tkinter support
  depends_on 'tk' => :build unless ARCH == 'i686' # Needed for tkinter support
  depends_on 'util_linux' # R
  depends_on 'xzutils' # R
  depends_on 'zlibpkg' # R
  depends_on 'zoneinfo' # L

  no_env_options
  conflicts_ok

  def self.preinstall
    @device = JSON.load_file("#{CREW_CONFIG_PATH}/device.json", symbolize_names: true)
    @replaces = %w[py3_pip py3_setuptools]
    @replaces_installed = []
    @replaces.each do |package|
      @replaces_installed.push(package) if @device[:installed_packages].any? { |elem| elem[:name] == package }
    end
    return if @replaces_installed.empty?

    puts "Removing superseded package(s): #{@replaces_installed.join(' ')}...".orange
    system "crew remove #{@replaces_installed.join(' ')}", exception: false
  end

  def self.prebuild
    # Ensure that internal copies of expat, libffi and zlib aren't used
    FileUtils.rm_rf 'Modules/expat'
    FileUtils.rm_rf Dir.glob('Modules/_ctypes/libffi*')
    FileUtils.rm_rf 'Modules/zlib'
  end

  def self.build
    @cppflags = "-I#{CREW_PREFIX}/include/ncursesw"
    # Using /tmp breaks test_distutils, test_subprocess.
    # Proxy setting breaks test_httpservers, test_ssl,
    # test_urllib, test_urllib2, test_urllib2_localnet.
    # So, modifying environment variable to make pass tests.

    return if Dir.exist?('builddir')

    FileUtils.mkdir_p 'builddir'
    Dir.chdir 'builddir' do
      system CREW_ENV_OPTIONS_HASH.transform_values { |v|
               "#{v} #{@cppflags}"
             }, "LD_LIBRARY_PATH=#{CREW_LIB_PREFIX} ../configure #{CREW_OPTIONS} \
          --with-lto \
          --with-computed-gotos \
          --enable-loadable-sqlite-extensions \
          --with-ensurepip \
          --enable-optimizations \
          --with-platlibdir='lib#{CREW_LIB_SUFFIX}' \
          --with-system-expat \
          --with-system-libmpdec \
          --with-tzpath=#{CREW_PREFIX}/share/zoneinfo \
          --with-libc= \
          --enable-shared"
      system 'mold -run make'
      File.write 'python_config_env', <<~PYTHON_CONFIG_EOF
        # Force use of python3 over python2.7 in packages which check the variable to set the python used.
        PYTHON=python3
      PYTHON_CONFIG_EOF
    end
  end

  def self.check
    # Chromebooks do not allow SIGHUP, so disable SIGHUP test
    system 'sed', '-i', 'Lib/test/test_asyncio/test_events.py', '-e', "/Don't have SIGHUP/s/win32/linux/"
    system 'sed', '-i', 'Lib/test/test_asyncio/test_subprocess.py', '-e', "/Don't have SIGHUP/s/win32/linux/"

    # Chromebooks return EINVAL for F_NOTIFY DN_MULTISHOT, so disable test_fcntl_64_bit
    system 'sed', '-i', 'Lib/test/test_fcntl.py', '-e', '/ARM Linux returns EINVAL for F_NOTIFY DN_MULTISHOT/s/$/\
    @unittest.skipIf(platform.system() == '"'Linux'"', "Chromeos returns EINVAL for F_NOTIFY DN_MULTISHOT")/'

    # imaplib test used to use a kind of security hole on a server in university and the hole is closed now.
    # See https://bugs.python.org/issue30175 and https://github.com/python/cpython/pull/1320/files for details.
    system 'sed', '-i', 'Lib/test/test_imaplib.py',
           '-e', '/test_logincapa_with_client_certfile/i\ \ \ \ @unittest.skipIf(True,\
                     "bpo-30175: FIXME: cyrus.andrew.cmu.edu doesn\'t accept "\
                     "our randomly generated client x509 certificate anymore")',
           '-e', '/test_logincapa_with_client_ssl_context/i\ \ \ \ @unittest.skipIf(True,\
                     "bpo-30175: FIXME: cyrus.andrew.cmu.edu doesn\'t accept "\
                     "our randomly generated client x509 certificate anymore")'

    # Using /tmp breaks test_distutils, test_subprocess
    # Proxy setting breaks test_httpservers, test_ssl,
    # test_urllib, test_urllib2, test_urllib2_localnet
    # system "http_proxy= https_proxy= ftp_proxy= make test"
  end

  def self.install
    Dir.chdir 'builddir' do
      system 'make', "DESTDIR=#{CREW_DEST_DIR}", 'install'
      # There is a Python ABI break in 3.11.5 coming from 3.11.4, see https://github.com/python/cpython/issues/108525
      system "LD_LIBRARY_PATH=#{CREW_DEST_LIB_PREFIX}:#{CREW_LIB_PREFIX} #{CREW_DEST_PREFIX}/bin/python3 -m ensurepip --upgrade --default-pip"
      system "sed -i 's,#{CREW_DEST_PREFIX}/bin/python3,#{CREW_PREFIX}/bin/python3,g' #{CREW_DEST_PREFIX}/bin/pip3"
    end

    # Make python3 the default python
    FileUtils.ln_sf 'python3', "#{CREW_DEST_PREFIX}/bin/python"
    FileUtils.ln_sf 'pip3', "#{CREW_DEST_PREFIX}/bin/pip"
    FileUtils.install 'builddir/python_config_env', "#{CREW_DEST_PREFIX}/etc/env.d/python", mode: 0o644
  end

  def self.postinstall
    # Pip is installed inside Python 3. The following steps ensure that
    # pip can properly build other packages from buildsystems/pip.
    @required_pip_modules = %w[build installer setuptools wheel pyproject_hooks]
    @pip_list = `pip list --exclude pip`
    @required_pip_modules.each do |pip_pkg|
      unless @pip_list.include?(pip_pkg)
        puts "Installing #{pip_pkg} using pip..."
        system "MAKEFLAGS=-j#{CREW_NPROC} pip install #{pip_pkg}"
      end
    end

    puts 'Updating pip packages...'.lightblue
    system 'pip list --outdated --format=json | python -c "import json, sys; print(\'\n\'.join([x[\'name\'] for x in json.load(sys.stdin)]))" | xargs -rn1 pip install -U', exception: false
    puts "Please install tcl and tk with 'crew install tcl tk' if tkinter is needed.".lightblue unless ARCH == 'i686'
  end
end
