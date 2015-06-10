class AllParams < ParamsBase
  def initialize(params, request_params)
    @params = params
    @request_params = request_params

    # this class acts as a virtual hash on top of two real hashes for all write-related methods (which need to be overriden)
    # the values from both hashes are also synchronized in this class to avoid having to override all read-related methods
    self.merge!(@params)
    self.merge!(@request_params)
  end

  alias :super_add :[]=

  def []=(key,val)
    raise RuntimeError.new("This is a virtual hash based on two physical hashes, use the add method instead.")
  end

  #TODO: refactor out the where functionality
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
  def add(key, value, store)
    if store == "params"
      @params[key] = value
    elsif store == "json"
      @request_params[key] = value
    end
    super_add(key, value)
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