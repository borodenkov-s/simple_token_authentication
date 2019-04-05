require 'active_support/concern'
require 'simple_token_authentication/token_generator'

module SimpleTokenAuthentication
  module ActsAsAuthenticationToken
    extend ::ActiveSupport::Concern

    # Please see https://gist.github.com/josevalim/fb706b1e933ef01e4fb6
    # before editing this file, the discussion is very interesting.

    included do
      private :generate_token
      private :token_suitable?
      private :token_generator

      scope :active, ->{ where('expires_at > ?', Date.today) }
    end


    # Set an authentication token if missing
    #
    # Because it is intended to be used as a filter,
    # this method is -and should be kept- idempotent.
    def ensure_token_present
      self.expires_at = Date.today + self.class::EXPIRATION_DELAY
      self.token      = generate_token(token_generator) if token.blank?
    end

    def generate_token(token_generator)
      loop do
        token = token_generator.generate_token
        break token if token_suitable?(token)
      end
    end

    def token_suitable?(token)
      self.class.where(token: token).count.zero?
    end

    def token_generator
      TokenGenerator.instance
    end

    module ClassMethods
      def acts_as_authentication_token(options = {})
        unless self.const_defined?(:EXPIRATION_DELAY)
          self.const_set :EXPIRATION_DELAY, options[:expiration_delay] || 1.week
        end

        before_save :ensure_token_present
      end
    end
  end
end
