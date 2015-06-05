class RequestParams < ParamsBase
  attr_reader :file_path

  def initialize(path)
    @file_path = "#{path}/request_data.json"

    self.merge!(get_request_params)
  end

  def self.new_for_request(automation_results_dir, app_name, request_id)
    self.new("#{automation_results_dir}/request/#{app_name}/#{request_id}")
  end

  def []=(key,val)
    super(key, val)

    set_request_params
  end

  # Gets a params
  #
  # ==== Attributes
  #
  # * +key+ - key to find
  def get(key, default_value = "")
    result = self.has_key?(key) ? self[key] : nil
    result = default_value if result.nil? || result == ""

    BrpmAuto.substitute_tokens(result)
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
  def add(key_name, value)
    self[key_name] = value
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
  def find_or_add(key_name, value)
    ans = get(key_name)
    add(key_name, value) if ans == ""
    ans == "" ? value : ans
  end

  #TODO: support parallel steps modifying the same request params file

  private

    def set_request_params
      request_params_file = File.new(@file_path, "w")
      request_params_file.puts(self.to_json)
      request_params_file.close
    end

    def get_request_params
      if File.exist?(@file_path)
        json = File.read(@file_path)
        JSON.parse(json)
      else
        {}
      end
    end
end
