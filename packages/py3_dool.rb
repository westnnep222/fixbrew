require 'buildsystems/pip'

class Py3_dool < Pip
  description 'Dool is a command line tool to monitor many aspects of your system: CPU, Memory, Network, Load Average, etc.'
  homepage 'https://github.com/scottchiefbaker/dool'
  version '1.3.2-py3.12'
  license 'GPL3+'
  compatibility 'all'
  source_url 'SKIP'
  binary_compression 'tar.zst'

  depends_on 'python3'

  no_compile_needed
end
