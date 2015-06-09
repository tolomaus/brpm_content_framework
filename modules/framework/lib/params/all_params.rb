class AllParams < ParamsBase
  def initialize(params, request_params)
    @params = params
    @request_params = request_params
  end

  def [] key
    @params.has_key?(key) ? @params[key] : @request_params[key]
  end

  def []=(key,val)
    raise RuntimeError.new("This is a virtual hash based on two physical hashes, use the add method instead.")
  end

  # Finds a key in params or json_params
  #
  # ==== Attributes
  #
  # * +key_name+ - key name
  # * +default+ - value to return if key is blank or not found
  #
  # ==== Returns
  #
  # * value of key - including resolved properties that may be embedded
  # *  Like this: /opt/bmc/${component_version}/appserver
  def get(key_name, default = "")
    ans = nil
    ans = @params.get(key_name) if @params.has_key?(key_name)
    ans = @request_params.get(key_name) if @request_params.has_key?(key_name)
    ans = default if ans.nil? || ans == ""
  end

  # Test if a param is present
  #
  # ==== Attributes
  #
  # * +key_name+ - key to look for
  # * +where+ - if true returns the hash where the key was found
  #
  # ==== Returns
  #
  # * the param hash name if where=true, otherwise true/false
  def present?(key_name, where = false)
    ans = nil
    ans = "params" if @params.has_key?(key_name)
    ans = "json" if @request_params.has_key?(key_name)
    where ? ans : !ans.nil?
  end

  def present_json?(key_name)
    @request_params.has_key?(key_name)
  end

  def present_local?(key_name)
    @params.has_key?(key_name)
  end

  # Adds a key/value to the params
  #
  # ==== Attributes
  #
  # * +key_name+ - key name
  # * +value+ - value to assign
  #
  # ==== Returns
  #
  # * value added
  def add(key_name, value, store)
    if store == "params"
      @params[key_name] = value
    elsif store == "json" or store == "request_params"
      @request_params[key_name] = value
    end
  end

  # Adds a key/value to the params if not found
  #
  # ==== Attributes
  #
  # * +key_name+ - key name
  # * +value+ - value to assign
  #
  # ==== Returns
  #
  # * value of key
  def find_or_add(key_name, value, store)
    ans = get(key_name)
    add(key_name, value, store) if ans == ""
    ans == "" ? value : ans
  end
end