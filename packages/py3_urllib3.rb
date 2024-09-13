require 'buildsystems/pip'

class Py3_urllib3 < Pip
  description 'URLlib3 is an HTTP library with thread-safe connection pooling, file post, and more.'
  homepage 'https://urllib3.readthedocs.io/'
  version '2.2.3-py3.12'
  license 'MIT'
  compatibility 'all'
  source_url 'SKIP'

  depends_on 'python3' => :build

  no_compile_needed
end
