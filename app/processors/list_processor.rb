# frozen_string_literal: true

CREATABLE_LIST_TYPES = ['list']

class ListProcessor < JSONAPI::Processor
  before_create_resource do
    list_type = params[:data][:attributes][:list_type]
    unless CREATABLE_LIST_TYPES.include?(list_type)
      raise JSONAPI::Exceptions::InvalidFieldValue.new(:list_type, list_type)
    end
  end
end
