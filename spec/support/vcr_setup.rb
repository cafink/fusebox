require 'vcr'

VCR.configure do |c|
  c.default_cassette_options = { :match_requests_on => [ :method, :uri, :query ] }
  c.cassette_library_dir = 'vcr_cassettes'
  c.hook_into :webmock
end
