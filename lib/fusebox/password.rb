require 'keepass/password'

module Fusebox
  class Password

    MIN_LENGTH = 8

    def initialize (length = MIN_LENGTH)
      @length = length < MIN_LENGTH ? MIN_LENGTH : length
    end

    def generate
      KeePass::Password.generate password_format
    end

    private

    # Password requirements:
    # - at least 8 characters long
    # - at least one upper-case letter
    # - at least one number
    # - at least one symbol
    def password_format
      # Don't use string interpolation because of # in the pattern.
      'ud[\!\@\#\$\-\=\_\+\*][A\!\@\#\$\-\=\_\+\*]{' + (@length - 3).to_s + '}'
    end

  end
end
