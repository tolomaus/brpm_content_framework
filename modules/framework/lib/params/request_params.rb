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
