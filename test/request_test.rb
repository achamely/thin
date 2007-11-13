require File.dirname(__FILE__) + '/test_helper'

class RequestTest < Test::Unit::TestCase
  def test_parse_path
    request = Fart::Request.new(<<-EOS)
GET /index.html HTTP/1.1
EOS
    assert_equal 'GET', request.verb
    assert_equal '/index.html', request.path
  end
  
  def test_parse_path_with_query_string
    request = Fart::Request.new(<<-EOS)
GET /index.html?234235 HTTP/1.1
EOS
    assert_equal 'GET', request.verb
    assert_equal '/index.html', request.path
  end
  
  def test_parse_headers
    request = Fart::Request.new(<<-EOS)
GET / HTTP/1.1
Host: localhost:3000
User-Agent: Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.9) Gecko/20071025 Firefox/2.0.0.9
Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5
Accept-Language: en-us,en;q=0.5
Accept-Encoding: gzip,deflate
Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7
Cookie: mium=7
Keep-Alive: 300
Connection: keep-alive
EOS
    assert_equal 'localhost:3000', request.params['HTTP_HOST']
    assert_equal 'mium=7', request.params['HTTP_COOKIE']
  end
  
  def test_parse_headers
    request = Fart::Request.new(<<-EOS)
GET /page?cool=thing HTTP/1.1
Host: localhost:3000
Keep-Alive: 300
Connection: keep-alive
EOS
    assert_equal 'cool=thing', request.params['QUERY_STRING']
    assert_equal '/page?cool=thing', request.params['REQUEST_URI']
    assert_equal '/page', request.path
  end
  
  def test_parse_post_data
    request = Fart::Request.new(<<-EOS.chomp)
POST /postit HTTP/1.1
Host: localhost:3000
User-Agent: Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.9) Gecko/20071025 Firefox/2.0.0.9
Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5
Accept-Language: en-us,en;q=0.5
Accept-Encoding: gzip,deflate
Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7
Keep-Alive: 300
Connection: keep-alive
Content-Type: text/html
Content-Length: 37

name=marc&email=macournoyer@gmail.com
EOS
    
    assert_equal 'POST', request.params['REQUEST_METHOD']
    assert_equal '/postit', request.params['REQUEST_URI']
    assert_equal 'text/html', request.params['CONTENT_TYPE']
    assert_equal '37', request.params['CONTENT_LENGTH']
    assert_equal 'name=marc&email=macournoyer@gmail.com', request.params['RAW_POST_DATA']
  end
  
  def test_parse_perfs
    body = <<-EOS.chomp
POST /postit HTTP/1.1
Host: localhost:3000
User-Agent: Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.9) Gecko/20071025 Firefox/2.0.0.9
Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5
Accept-Language: en-us,en;q=0.5
Accept-Encoding: gzip,deflate
Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7
Keep-Alive: 300
Connection: keep-alive
Content-Type: text/html
Content-Length: 37

hi=there#{'&name=marc&email=macournoyer@gmail.com'*1000}
EOS
    Benchmark.bm do |x|
      x.report('baseline') { body.match /.*/ }
      x.report('   parse') { Fart::Request.new(body) }
    end
    #           user       system     total       real
    # 1) parse  0.000000   0.000000   0.000000 (  0.000379)
    # 2) parse  0.000000   0.000000   0.000000 (  0.000157)
    # 3) parse  0.000000   0.000000   0.000000 (  0.000111)
    # 4) parse  0.000000   0.000000   0.000000 (  0.000103)
  end
end