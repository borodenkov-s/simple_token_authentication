require 'active_support/concern'

module SimpleTokenAuthentication
  module ActsAsTokenAuthenticatable
    extend ::ActiveSupport::Concern

    # Please see https://gist.github.com/josevalim/fb706b1e933ef01e4fb6
    # before editing this file, the discussion is very interesting.

    def authentication_token_for(user_agent)
      authentication_tokens.active.find_by_user_agent(user_agent).try(:token)
    end

    module ClassMethods
      def acts_as_token_authenticatable(options = {})
        foreign_key = options[:foreign_key] || "#{self.name.downcase}_id"

        has_many :authentication_tokens,
                 dependent: :destroy,
                 foreign_key: foreign_key
      end
    end
  end
end
