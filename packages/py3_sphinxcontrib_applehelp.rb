require 'buildsystems/pip'

class Py3_sphinxcontrib_applehelp < Pip
  description 'sphinxcontrib-applehelp is a sphinx extension which outputs Apple help books.'
  homepage 'https://www.sphinx-doc.org/'
  version '2.0.0-py3.12'
  license 'BSD'
  compatibility 'all'
  source_url 'SKIP'
  binary_compression 'tar.zst'

  depends_on 'python3' => :build

  no_compile_needed
end
