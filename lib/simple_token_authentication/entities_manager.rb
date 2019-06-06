require 'simple_token_authentication/entity'

module SimpleTokenAuthentication
  class EntitiesManager
    def find_or_create_entity(model, model_alias=nil, association_name = nil)
      @entities ||= {}
      @entities[model.name] ||= Entity.new(model, model_alias, association_name)
    end
  end
end
