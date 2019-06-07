require 'active_support/concern'

module SimpleTokenAuthentication
  module ActsAsTokenAuthenticatable
    extend ::ActiveSupport::Concern

    # Please see https://gist.github.com/josevalim/fb706b1e933ef01e4fb6
    # before editing this file, the discussion is very interesting.

    module ClassMethods
      def acts_as_token_authenticatable(options = {})
        foreign_key      = options[:foreign_key] || "#{self.name.downcase}_id"
        association_name = options[:association_name] || :authentication_tokens

        has_many association_name, dependent: :destroy, foreign_key: foreign_key
      end
    end
  end
end
