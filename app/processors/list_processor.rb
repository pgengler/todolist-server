# frozen_string_literal: true

class UncreatableListType < JSONAPI::Exceptions::Error
  attr_reader :list_type

  def initialize(list_type, error_object_overrides = {})
    @list_type = list_type
    super(error_object_overrides)
  end

  def errors
    message = "'#{@list_type}' lists cannot be created"
    [create_error_object(code: JSONAPI::VALIDATION_ERROR,
                        status: :unprocessable_entity,
                        title: message,
                        detail: "list-type - #{message}",
                        source: { pointer: '/data/attributes/list-type' })]
  end
end

class ListProcessor < JSONAPI::Processor
  before_create_resource do
    list_type = params[:data][:attributes][:list_type]
    unless List::CREATABLE_LIST_TYPES.include?(list_type)
      raise UncreatableListType.new(list_type)
    end
  end
end
