module SimpleTokenAuthentication
  class Entity
    def initialize(model, model_alias=nil)
      @model           = model
      @name            = model.name
      @identifier      = nil
      @name_underscore = model_alias.to_s unless model_alias.nil?
    end

    def model
      @model
    end

    def name
      @name
    end

    def identifier
      @identifier
    end

    def name_underscore
      @name_underscore || name.underscore
    end

    # Private: Return the name of the header to watch for the token authentication param
    def token_header_name
      return "X-#{name_underscore.camelize}-Token" unless header_names.present?

      header_names[:authentication_token]
    end

    # Private: Return the names of the header to watch for the email param
    def identifier_header_names
      if header_names.present?
        identifiers.each_with_object({}) do |identifier, result|
          result[identifier.to_sym] = header_names[identifier]
        end
      else
        identifiers.each_with_object({}) do |identifier, result|
          result[identifier.to_sym] = "X-#{name_underscore.camelize}-#{identifier.to_s.camelize}"
        end
      end
    end

    def token_param_name
      "#{name_underscore}_token".to_sym
    end

    def identifier_param_names
      identifiers.each_with_object({}) do |identifier, result|
        result[identifier.to_sym] = "#{name_underscore}_#{identifier}".to_sym
      end
    end

    def header_names
      @header_names ||= SimpleTokenAuthentication.header_names["#{name_underscore}".to_sym]
    end

    def identifiers
      return Array(custom_identifiers) if custom_identifiers.present?

      Array(:email)
    end

    def custom_identifiers
      @custom_identifiers ||= Array(SimpleTokenAuthentication.identifiers["#{name_underscore}".to_sym]).map &:to_sym
    end

    def get_token_from_params_or_headers controller
      # if the token is not present among params, get it from headers
      if token = controller.params[token_param_name].blank? && controller.request.headers[token_header_name]
        controller.params[token_param_name] = token
      end
      controller.params[token_param_name]
    end

    def get_identifier_from_params_or_headers controller
      # if the identifier is not present among params, get it from headers

      fetch_identifier_from_params(controller) || fetch_identifier_from_headers(controller)
    end

    def fetch_identifier_from_params(controller)
      identifier_param_names.each do |identifier, param_name|
        if (identifier_value = controller.params[param_name]).present?
          @identifier = identifier

          return identifier_value
        end
      end

      false
    end

    def fetch_identifier_from_headers(controller)
      identifier_header_names.each do |identifier, param_name|
        if (identifier_value = controller.request.headers[param_name]).present?
          @identifier = identifier

          return identifier_value
        end
      end

      false
    end
  end
end
