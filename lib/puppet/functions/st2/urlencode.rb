require 'cgi'

# URL encodes a string
Puppet::Functions.create_function(:'st2::urlencode') do
  # @param url Raw URL data to encode
  # @return [String] URL encoded data
  # @example Basic usage
  #   st2::urlencode('xyz!123')
  dispatch :urlencode do
    param 'String', :url
  end

  def urlencode(url)
    CGI.escape(url)
  end
end
