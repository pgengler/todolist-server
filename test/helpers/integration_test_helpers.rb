module IntegrationTestHelpers
  def json_api_delete(url, **args)
    add_headers_to_args(args)
    delete url, **args
  end

  def json_api_get(url, **args)
    add_headers_to_args(args)
    get url, **args
  end

  def json_api_patch(url, **args)
    add_headers_to_args(args)
    patch url, **args
  end

  def json_api_post(url, **args)
    add_headers_to_args(args)
    post url, **args
  end

  def add_headers_to_args(args)
    args[:headers] ||= { }
    args[:headers]['Content-Type'] ||= 'application/vnd.api+json'
    args[:headers]['Accept'] ||= 'application/vnd.api+json'
  end
end
