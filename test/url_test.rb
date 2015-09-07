require 'minitest/autorun'

require_relative '../lib/httpbench'

class TestURI < Minitest::Test
  EXAMPLES = { 'http://google.com/search' => { scheme: 'http',
                                               host: 'google.com',
                                               port: 80,
                                               path: '/search' },
               'google.com' => { scheme: 'http',
                                 host: 'google.com',
                                 port: 80,
                                 path: '/' },
               'https://facebook.com' => { scheme: 'https',
                                           host: 'facebook.com',
                                           port: 443,
                                           path: '/' },
               'facebook.com:443' => { scheme: 'https',
                                       host: 'facebook.com',
                                       port: 443,
                                       path: '/' },
               'target.local:1234' => { scheme: 'http',
                                        host: 'target.local',
                                        port: 1234,
                                        path: '/' }
             }

  def test_uri_parsing
    EXAMPLES.each_pair do |url, r|
      uri = HTTPBench::URL.parse url
      assert_equal(r, { scheme: uri.scheme,
                        host: uri.host,
                        port: uri.port,
                        path: uri.path },
                   url)
    end
  end
end
