require 'package'
Package.load_package("#{__dir__}/glibc_build223.rb")
Package.load_package("#{__dir__}/glibc_build227.rb")
Package.load_package("#{__dir__}/glibc_build232.rb")
Package.load_package("#{__dir__}/glibc_build233.rb")
Package.load_package("#{__dir__}/glibc_build235.rb")
Package.load_package("#{__dir__}/glibc_build237.rb")
Package.load_package("#{__dir__}/glibc_build238.rb")

class Glibc < Package
  description 'The GNU C Library project provides the core libraries for GNU/Linux systems.'
  homepage Glibc_build238.homepage
  license Glibc_build238.license

  is_fake

  case LIBC_VERSION
  when '2.23'
    version Glibc_build223.version
    compatibility Glibc_build223.compatibility
    depends_on 'glibc_build223'
  when '2.27'
    version Glibc_build227.version
    compatibility Glibc_build227.compatibility
    depends_on 'glibc_build227'
  when '2.32'
    version Glibc_build232.version
    compatibility Glibc_build232.compatibility
    depends_on 'glibc_build232'
  when '2.33'
    version Glibc_build233.version
    compatibility Glibc_build233.compatibility
    depends_on 'glibc_build233'
  when '2.35'
    version Glibc_build235.version
    compatibility Glibc_build235.compatibility
    depends_on 'glibc_lib235'
  when '2.37'
    version Glibc_build237.version
    compatibility Glibc_build237.compatibility
    depends_on 'glibc_lib237'
  when '2.38'
    version Glibc_build238.version
    compatibility Glibc_build238.compatibility
    depends_on 'glibc_lib238'
  else
    version LIBC_VERSION
    compatibility 'x86_64 aarch64 armv7l'
    depends_on 'glibc_fallthrough'
  end
end
