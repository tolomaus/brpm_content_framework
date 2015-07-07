# BRPM Content framework

[![Build Status](https://travis-ci.org/BMC-RLM/brpm_content.svg?branch=master)](https://travis-ci.org/BMC-RLM/brpm_content)

[![Gem Version](https://badge.fury.io/rb/brpm_content.png)](http://badge.fury.io/rb/brpm_content)

The BRPM Content framework is intended to make the creation and usage of content (for the moment limited to automation scripts) on top of BRPM as easy as possible.

It is designed around a number of core concepts like modularity, re-usability, testability that are further explained below.

## Getting started

### Installation

First of all, make sure that the environment variable BRPM_HOME is set to the location where BRPM is installed, e.g.:
```shell
export BRPM_HOME=/opt/bmc/RLM
```

Then copy the [BRPM Content framework's installation script](https://raw.githubusercontent.com/BMC-RLM/brpm_content/master/infrastructure/shell_scripts/install_content_repo.sh) to the instance on which BRPM is installed and execute it.

See here the commands to get you started:
```shell
wget https://raw.githubusercontent.com/BMC-RLM/brpm_content/master/infrastructure/shell_scripts/install_content_repo.sh
chmod +x install_content_repo.sh
./install_content_repo.sh
```

The script will ask for the location of a zip file that contains the files. If the BRPM instance has access to the internet you can leave it empty in which case it will directly grab the files from this github.com repo.
If you need the zip file of this repo you can find it on [https://github.com/BMC-RLM/brpm_content/archive/master.zip](https://github.com/BMC-RLM/brpm_content/archive/master.zip)

Alternatively, if the BRPM instance has internet access and wget is installed the framework can be installed by simply executing the following command on the BRPM instance as root:
```shell
wget -qO- https://raw.githubusercontent.com/BMC-RLM/brpm_content/master/infrastructure/shell_scripts/install_content_repo.sh | INSTALL=ONLINE sh
```

### Configuration

At this early stage it is still necessary to manually configure the automation scripts that come with this content repository in BRPM before you can start using them in the request steps. 

This can be done as following:
 - go to Environment > Automation and create an automation script
 - choose the type and category of the automation script
 - paste the content of the automation script's wrapper file (the file with the same name as the automation script but with the .txt extension) into the script body
 
The above remark applies to both automation scripts as well as resource automation scripts
 
Finally, make sure that the following item is added to Metadata > Lists > AutomationErrors: 
```
******** ERROR ********
```
This will allow non caught exceptions from the automation scripts to cause the step to go in problem mode.

## Architecture

The BRPM Content framework is an automation platform that is built on top of BRPM. It allows to create, install and run what are called modules that contain automation logic that naturally belongs together. The framework itself provides a number of general purpose features like an automation script executor, dependency management, parameter handling, logging, etc.
 
![alt text](https://github.com/BMC-RLM/brpm_content/blob/master/architecture.png "architecture")

The BRPM Content framework was built with the following design principles in mind, all further explained in the remainder of this document: 
- **modularity**
- **re-usability**
- **testability**
- **developer-friendliness**.

## Modularity

### Using existing modules

One of the core design principles of the framework is its modularity. The framework itself is deliberately chosen to be very lightweight. The purpose is that all custom automation logic is added by means of modules. Modules will typically group multiple automation scripts, resource automation scripts and libraries of one specific domain.

Modules can be installed by executing the [module installation](https://github.com/BMC-RLM/brpm_content/blob/master/infrastructure/shell_scripts/install_content_module.sh) script on the BRPM instance: 
```shell
~/shell_scripts/install_content_module.sh
```

The script will ask for the location of a zip file or the url of a github.com repository that contains the module's files. For the Selenium module this url would be [https://github.com/BMC-RLM/brpm_module_selenium](https://github.com/BMC-RLM/brpm_module_selenium).

Note that the BRPM Content framework contains a number of core [modules](https://github.com/BMC-RLM/brpm_content/tree/master/modules) that will be installed by default. The purpose is to gradually move these built-in modules into their own dedicated github repositories.  

### Creating your own modules

It is very simple to create your own module. 

Just make sure to stick with the following file structure: 
```
+-- automations
|   +-- my_automation_script.rb
|   +-- my_automation_script.txt
+-- resource_automations
|   +-- my_resource_automation_script.rb
|   +-- my_resource_automation_script.txt
+-- lib
|   +-- my_library.rb
+-- tests
|   +-- my_automation_script_spec.rb
|   +-- spec_helper.rb
+-- config.yml
```

The config.yml file contains the integration server and all other modules it depends on. Both settings are optional. In the future it will also be possible to version modules.

If you use a github.com repository to host the source code of the module you can directly install it from there. Otherwise you can create a zip file of the module and install it as such.

It is also possible to execute (and debug if your ruby IDE supports it, e.g. RubyMine) the scripts on your development machine. See further the section on Testability. 
 
For an example see the [Selenium](https://github.com/BMC-RLM/brpm_module_selenium) module.

## Re-usability

### Automation scripts

Although the initial purpose of the BRPM Content framework is to exist on top of BRPM, it is perfectly possible to use it outside of BRPM. Let's say that you initially developed an automation script for usage within BRPM but now you need to run it from Jenkins, a shell script, or even a unit test? As the framework is highly decoupled from BRPM nothing prevents you from doing this.

As an example, see here how the create_package automation script from the bladelogic module can be executed in stand-alone mode:                                                                                                                                                                                                                                                                                                                                                                                               

```ruby
# Load the BRPM Content framework's script executor
require "modules/framework/brpm_script_executor"

# Supply the input parameters for the automation script, if any
params = {}
params["application"] = "E-Finance"
params["component"] = "EF - Java calculation engine"
params["component_version"] = "1.2.3"

params["SS_integration_dns"] = "bladelogic"
params["SS_integration_username"] = "brpm"
params["SS_integration_password"] = "password"

# Execute the automation script
BrpmScriptExecutor.execute_automation_script("bladelogic", "create_package", params)
```
[source](https://github.com/BMC-RLM/brpm_content/blob/master/infrastructure/shell_scripts/create_bl_package.sh)

### Libraries

It is also possible to re-use the module's libraries in stand-alone mode:

```ruby
# Load the BRPM Content framework 
require "framework/brpm_auto"

# Set up the framework and load the brpm module
BrpmAuto.setup()
BrpmAuto.require_module "brpm"

# Create a BRPM REST client and find all requests for application E-Finance
@brpm_rest_client = BrpmRestClient.new("http://my-brpm-server/brpm', "<api token>")

app = @brpm_rest_client.get_app_by_name("E-Finance")
requests = @brpm_rest_client.get_requests_by({ "app_id" => app["id"]})
```

## Testability

Thanks to the decoupling between the BRPM Content framework and BRPM itself, it is very easy to write automated tests for the automation logic that runs on top of the framework.
 
As an example, see here a unit test written in RSpec that will create a plan and a request in that plan:

```ruby
describe 'create release request' do
  ...
  describe 'in new plan' do
    it 'should create a plan from template and a request from template in that plan' do
      # Supply the input parameters for the automation script, if any
      params = {}
      params["application_name"] = 'E-Finance'
      params["application_version"] = '1.2.3'
      params["release_request_template_name"] = 'Release E-Finance'
      params["release_plan_template_name"] = 'E-Finance Release Plan'

      # Execute the automation script
      BrpmScriptExecutor.execute_automation_script("brpm", "create_release_request", params)

      # Verify that the request was created and linked to the plan
      @brpm_rest_client = BrpmRestClient.new("http://my-brpm-server/brpm', "<api token>")
      request = @brpm_rest_client.get_request_by_id(BrpmAuto.params["result"]["request_id"])

      expect(request["aasm_state"]).to eq("started")
      expect(request).to have_key("plan_member")
      expect(request["plan_member"]["plan"]["id"]).not_to be_nil
    end
  end
  ...
end
```
[source](https://github.com/BMC-RLM/brpm_content/blob/master/modules/brpm/tests/create_release_request_spec.rb)

The framework itself comes with a set of RSpec tests that are executed automatically by [Travis CI](https://travis-ci.org/) after each commit. The status can be consulted on top of this page.

When setting up an automated testing platform for your modules, make sure that the framework is installed before executing the tests. 

### Mac OS X

Clone this repository to a location that is side by side with your module's location. Then 'require' the brpm_script_executor in your spec_helper.rb:
```ruby
require_relative "../../../brpm_content/modules/framework/brpm_script_executor"
```

Make sure that you are running on ruby 1.9.3 and that all gem dependencies as specified in the Gemfile are installed.
 
### Travis CI

See the [.travis.yml](https://github.com/BMC-RLM/brpm_module_selenium/blob/master/.travis.yml) file in the Selenium module for more information on how to do this.

## Framework
### Dependency management

If you want to use a library or automation script from a different module you can indicate a dependency to that module in your own module's config.yml file. This will automatically make all libraries and automation modules available to all of the scripts in your own module. No need to add 'require' statements yourself.

### Parameters

The framework parses the input parameters it receives from the caller and stores them into an easy to use structure for usage by the automation scripts.

#### input params

Input params are the regular parameters that are received from the caller.

They can be used as following:
```ruby
application = BrpmAuto.params.application

my_custom_param = BrpmAuto.params["my_custom_param"]
```

Check out the [automated tests](https://github.com/BMC-RLM/brpm_content/blob/master/modules/framework/tests/params_spec.rb) for more complex use cases.

#### request params

Request params are special in the sense that they are kept over the whole life cycle of the request in which they exist. When one step needs information from a previous step this information can be stored as a request param.

They can be used as following:
- In step 1:
```ruby
BrpmAuto.request_params["created_issue_id"] = 123
```
- In step 2:
```ruby
BrpmAuto.log "The id of the issue that was created by step 1 is #{BrpmAuto.request_params["created_issue_id"]}"
```

Check out the [automated tests](https://github.com/BMC-RLM/brpm_content/blob/master/modules/framework/tests/request_params_spec.rb) for more complex use cases.

#### integration settings

The integration settings are the connection parameters that are needed to connect with the integration server that was defined for the automation script in BRPM. They are stored as part of the input params.

### Logging

You can use the built-in logging feature for any logging needs. The logs will be visible on the 'Notes' tab of the associated BRPM step after the automation is finished. You can also consult the logs in real-time by navigating to my_brpm_server/brpm/automation_results/log.html?request=request id

Example:
```ruby
BrpmAuto.log "Hello World"
```

### Error handling

Any ruby exception that is not trapped inside the automation scripts will cause the associated BRPM step to transition into problem state. This is also the only way to force the step into a problem state. If no exception is thrown the step will always be considered successful and the request will continue.

### Extensions

#### server yaml file

The framework allows you to define your own parameters that will automatically be made available to all automation scripts. You can do this by creating a file server.yml in $BRPM_HOME/config and adding your parameters into it, in YAML format. See [here](https://github.com/BMC-RLM/brpm_content/blob/master/modules/framework/config/server.yml) for an example. 

#### customer include file

The framework allows you to create your own ruby methods that you will automatically be able to use in all automation scripts. You can do this by creating a file customer_include.rb in $BRPM_HOME/config and adding your custom methods into it. See [here](https://github.com/BMC-RLM/brpm_content/blob/master/modules/framework/config/customer_include.rb) for an example.

Note
If a get_customer_include_params method exists, the framework will automatically execute it and add the resulting hash into the parameters hash.

This feature is deprecated. Consider creating a server.yml file for storing customer-specific parameters or creating a module for re-using customer-specific logic. 

### Other framework features
#### Execute command
#### Semaphores

## Integrations

The BRPM Content framework makes it easy to integrate with other tools using web hook and messaging technology. In both cases it is possible to execute an automation script (or use a library) whenever a notification is received.

### Web hook receivers

The framework contains a generic [web hook receiver script](https://github.com/BMC-RLM/brpm_content/blob/master/infrastructure/integrations/webhook_receiver.rb) with an associated [bash wrapper script](https://github.com/BMC-RLM/brpm_content/blob/master/infrastructure/shell_scripts/run_webhook_receiver.sh) that can be run as a daemon. You can pass it a custom script that can take care of processing the received events. Typically this event processing script will then execute the appropriate automation scripts.
 
A web hook receiver solution can be used for synchronizing data that is owned by another system (assuming it supports web hooks) with BRPM.

For an example of how to synchronize JIRA issues with BRPM tickets see the [event handler script](https://github.com/BMC-RLM/brpm_content/blob/master/customers/demo/integrations/jira/process_webhook_event.rb) that could be used for this purpose. As soon as the script is run in daemon mode (and JIRA is configured to send event notifications to a web hook) it will start receiving events when issues are created or updated. 

### Messaging engine

BRPM comes with a messaging engine that can send a notification for many events like the creation or update or requests, plans etc. The framework contains an [event handler script](https://github.com/BMC-RLM/brpm_content/blob/master/infrastructure/integrations/event_handler.rb) with an associated [bash wrapper script](https://github.com/BMC-RLM/brpm_content/blob/master/infrastructure/shell_scripts/run_event_handler.sh) that can be set up to listen to these incoming events. You can pass it a custom script that can take care of processing the received events. Typically this event processing script will then execute the appropriate automation scripts.

A messaging solution can be used for extending the out-of-the-box BRPM feature set or for synchronizing BRPM owned data with other systems. 

For an example of how to update the status of the associated JIRA tickets after a deployment request finished successfully see the [event handler script](https://github.com/BMC-RLM/brpm_content/blob/master/customers/demo/integrations/brpm/process_event_handler_event.rb) (search for update_tickets_in_jira_by_request) that could be used for this purpose. As soon as the script is run in daemon mode it will start receiving events when requests change status. 

## Modules
### BRPM   
### BladeLogic
### JIRA
### Jenkins

### [Selenium](https://github.com/BMC-RLM/brpm_module_selenium) (in progress)

