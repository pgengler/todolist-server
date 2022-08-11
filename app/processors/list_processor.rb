# frozen_string_literal: true

CREATABLE_LIST_TYPES = ['list']
UPDATABLE_LIST_TYPES = ['list']

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

class InvalidListTypeChange < JSONAPI::Exceptions::Error
  attr_reader :old_list_type, :new_list_type

  def initialize(old_list_type, new_list_type, error_object_overrides = {})
    @old_list_type = old_list_type
    @new_list_type = new_list_type
    super(error_object_overrides)
  end

  def errors
    message = "'#{@old_list_type}' lists cannot be changed to '#{@new_list_type}'"
    [create_error_object(code: JSONAPI::VALIDATION_ERROR,
                        status: :unprocessable_entity,
                        title: message,
                        detail: "list-type - #{message}",
                        source: { pointer: '/data/attributes/list-type' })]
  end
end

class ImmutableListType < JSONAPI::Exceptions::Error
  attr_reader :list_type

  def initialize(list_type, error_object_overrides = {})
    @list_type = list_type
    super(error_object_overrides)
  end

  def errors
    message = "'#{@list_type}' lists cannot have their list_type changed"
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
    unless CREATABLE_LIST_TYPES.include?(list_type)
      raise UncreatableListType.new(list_type)
    end
  end

  before_replace_fields do
    resource_id = params[:resource_id]
    resource = resource_klass.find_by_key(resource_id, context: context)
    unless UPDATABLE_LIST_TYPES.include?(resource.list_type)
      raise ImmutableListType.new(resource.list_type)
    end

    new_list_type = params[:data][:attributes][:list_type]
    unless UPDATABLE_LIST_TYPES.include?(new_list_type)
      raise InvalidListTypeChange.new(resource.list_type, new_list_type)
    end
  end
end
