class ParamsBase < Hash
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
  def method_missing(key_name, *args)
    ans = get(key_name.to_s)
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
  def required(key_name)
    raise "ParamsError: param #{key_name} must be present" unless self.has_key?(key_name)
    get(key_name)
  end

end