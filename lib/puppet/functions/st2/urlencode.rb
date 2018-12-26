require 'cgi'

Puppet::Functions.create_function(:'st2::urlencode') do
  dispatch :urlencode do
    param 'String', :url
  end

  def urlencode(url)
    CGI.escape(url)
  end
end
