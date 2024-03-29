class ParamsBase < Hash
  def [] key
    BrpmAuto.substitute_tokens(super(key))
  end

  # Gets a params
  #
  # ==== Attributes
  #
  # * +key+ - key to find
  def get(key, default_value = "")
    self[key] || default_value
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
  def add(key, value)
    self[key] = value
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
  def find_or_add(key, value)
    ans = get(key)
    add(key, value) if ans == ""
    ans == "" ? value : ans
  end

  # Allows you to specify a key like a method call
  #
  # ==== Attributes
  #
  # * +key_name+ - key name note: you must use get if keyname has spaces
  # * +*args+ - allows you to send a default value
  #
  # ==== Returns
  #
  # * value of key - including resolved properties that may be embedded
  #
  # ==== Examples
  #
  #   @p = Params.new(params)
  #   @p.SS_application
  #   => "Sales"
  def method_missing(key, *args)
    ans = get(key.to_s)
    ans = args[0] if ans == "" && args[0]
    ans
  end

  # Raises an error if a key is not found
  #
  # ==== Attributes
  #
  # * +key_name+ - key name
  #
  # ==== Returns
  #
  # * value of key
  def required(key)
    raise "ParamsError: param #{key} must be present" unless self.has_key?(key)
    get(key)
  end

end