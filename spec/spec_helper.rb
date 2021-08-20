require File.expand_path(File.dirname(__FILE__) + "/../lib/fusebox")
require File.expand_path(File.dirname(__FILE__) + "/support/vcr_setup.rb")

SPEC_DOMAIN      = SecureRandom.hex(4) + '.example.com'
SECONDARY_DOMAIN = SecureRandom.hex(4) + '.example.com'
FORWARD          = SecureRandom.hex(4) + "@#{SPEC_DOMAIN}"
SLEEP_DURATION   = 30 # How long the tests should sleep after the initial "order" to allow the data to propagate
