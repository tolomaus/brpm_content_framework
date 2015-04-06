require 'yaml'
require 'savon'

def ao_reserve_ip_address(host_name)
  input_param = {}
  input_param["name"] = "host_name"
  input_param["type"] = "xs:string"
  input_param["value"] = host_name

  response = ao_soap_request("Get IP address", [ input_param ])

  response[:parameter][:value][:xml_doc][:value]
end

def ao_execute_workflow(process_name, input_params)
  input_params_soap = []
  input_params.each do |name, value|
    input_param_soap = {}
    input_param_soap["name"] = name
    input_param_soap["type"] = "xs:string"
    input_param_soap["value"] = value

    input_params_soap << input_param_soap
  end

  response = ao_soap_request(process_name, input_params_soap)

  response[:parameter][:value][:xml_doc][:value]
end

def ao_soap_request(process_name, input_params)
  username = get_ao_soap_api_username
  password = get_ao_soap_api_password
  grid_name = get_ao_soap_api_grid_name
  module_name = get_ao_soap_api_module_name

  begin
    HTTPI.log = false
    Savon.configure do |config|
      config.log = false
    end

    namespaces = { "xmlns:soapenv" => "http://schemas.xmlsoap.org/soap/envelope/", "xmlns:soa" => "http://bmc.com/ao/xsd/2008/09/soa" }

    client = Savon.client(get_ao_soap_api_url)
    client.http.auth.ssl.verify_mode = :none

    response = client.request :execute_process do
      soap.xml do |xml|
        xml.soapenv(:Envelope, namespaces) do |xml|
          xml.soapenv(:Header) do |xml|
            xml.wsse(:Security, "soapenv:mustUnderstand" => "1", "xmlns:wsse" => "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd") do |xml|
              xml.wsse(:UsernameToken) do |xml|
                xml.wsse(:Username, username)
                xml.wsse(:Password, password, "Type" => "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText")
              end
            end
          end
          xml.soapenv(:Body) do |xml|
            xml.soa(:executeProcess) do |xml|
              xml.soa(:gridName, grid_name)
              xml.soa(:moduleName, module_name)
              xml.soa(:processName, ":#{module_name}:#{process_name}")
              xml.soa(:parameters) do |xml|
                xml.soa(:Input) do |xml|
                  input_params.each do |input_param|
                    xml.soa(:Parameter) do |xml|
                      xml.soa(:Name, input_param["name"], :required => true)
                      xml.soa(:Value, "soa:type" => input_param["type"]) do |xml|
                        xml.soa(:Text, input_param["value"])
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end

    response.body[:execute_process_response][:output][:output]
  rescue => e
    raise("AO SOAP request failed: #{e.message}\n#{e.backtrace}")
  end
end

def set_ao_soap_api_url(url)
  @url = url
end

def get_ao_soap_api_url()
  @url
end

def set_ao_soap_api_username(username)
  @username = username
end

def get_ao_soap_api_username()
  @username
end

def set_ao_soap_api_password(password)
  @password = password
end

def get_ao_soap_api_password()
  @password
end

def set_ao_soap_api_grid_name(grid_name)
  @grid_name = grid_name
end

def get_ao_soap_api_grid_name()
  @grid_name
end

def set_ao_soap_api_module_name(module_name)
  @module_name = module_name
end

def get_ao_soap_api_module_name()
  @module_name
end