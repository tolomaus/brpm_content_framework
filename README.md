# BRPM Content framework

[![Build Status](https://travis-ci.org/BMC-RLM/brpm_content_framework.svg?branch=master)](https://travis-ci.org/BMC-RLM/brpm_content_framework)

[![Gem Version](https://badge.fury.io/rb/brpm_content_framework.png)](http://badge.fury.io/rb/brpm_content_framework)

The BRPM Content framework is intended to make the creation and usage of content on top of BRPM as easy as possible. For the moment this content is limited to automation scripts, but in the future this could easily be extended to include sample applications, request templates, etc. 

It is designed around a number of core concepts like modularity, re-usability, testability that are further explained below.

## Getting started

### Installation

#### environment variables
First of all, make sure that the necessary environment variables are set on the BRPM instance, e.g. for a default BRPM installation:
```shell
export BRPM_HOME=/opt/bmc/RLM
export JAVA_HOME="$BRPM_HOME/lib/jre"
export JRUBY_HOME="$BRPM_HOME/lib/jruby"
export GEM_HOME="$BRPM_HOME/modules"

export PATH="$GEM_HOME/bin:$JRUBY_HOME/bin:$PATH"
```

If BRPM is installed on a custom location you can modify the first line accordingly. The PATH variable is modified to make sure the ruby scripts that come with the modules are in the PATH.  

#### .brpm
Then create a file .brpm with the following contents in the root directory of the user account that runs BRPM:
```shell
brpm_url: http://your-brpm-server:8088/brpm
brpm_api_token: ...
```

Note that he brpm_api_token should be the token of a user that is defined in BRPM and that has administrative rights.

#### framework
Finally you can install the framework and the BRPM module (needed to configure the automation script wrappers of the modules) as following:
```shell
gem install brpm_content_framework
brpm_install brpm_module_brpm
```

If the BRPM instance has no direct access to the internet you can also download the modules (which are basically ruby gems) to your workstation and upload them from there onto the BRPM instance.
 
In that case the installation can be done as following:
```shell
gem install /path/to/brpm_content_framework-x.x.x.gem --local
brpm_install /path/to/brpm_module_brpm-x.x.x.gem
```

Note that brpm_module_brpm is a module that contains a REST API client for BRPM and is needed to set up the automation scripts of the modules that will be installed later on.
 
Both gem files can be downloaded from the public gem repository rubygems.org. Just look up the name and on the gem's home page you will find a "Download" button that has a link to the latest version of the gem.

#### modules
OK now that the framework is installed the next thing to do is to install a couple of existing modules (or even build your own!). There is a list of available modules at the end of this page.

A module can be installed as following:
```shell
brpm_install module-name
```

Or if the BRPM instance has no direct access to the internet (assuming the gem file was manually uploaded onto the instance):
```shell
brpm_install /path/to/module-name-x.x.x.gem
```

The gem file of the module can be found on rubygems.org. 

### Usage
Once the module is installed you can immediately start using its contained automation scripts by linking the requests' steps to them.  

## Architecture

The BRPM Content framework is an automation platform that is built on top of BRPM. It allows to create, install and run what are called modules that contain automation logic that naturally belongs together. The framework itself provides a number of general purpose features like an automation script executor, dependency management, parameter handling, logging, etc.
 
![alt text](https://github.com/BMC-RLM/brpm_content_framework/blob/master/architecture.png "architecture")

The BRPM Content framework was built with the following design principles in mind, all further explained in the remainder of this document: 
- **modularity**
- **re-usability**
- **testability**
- **developer-friendliness**.

## Modularity

### Using existing modules

One of the core design principles of the framework is its modularity. The framework itself is deliberately chosen to be very lightweight. The purpose is to add all custom automation logic through modules. Modules will typically group multiple automation scripts, resource automation scripts and libraries of one specific domain or topic.

### Creating your own modules

It is very simple to create your own module. 

Just make sure to stick with the following [file structure](https://github.com/BMC-RLM/brpm_content_framework/tree/master/infrastructure/module_template): 
```
+-- automations
|   +-- my_automation_script.rb
|   +-- my_automation_script.meta
+-- resource_automations
|   +-- my_resource_automation_script.rb
|   +-- my_resource_automation_script.meta
+-- lib
|   +-- my_library.rb
+-- tests
|   +-- my_automation_script_spec.rb
|   +-- spec_helper.rb
+-- config.yml
+-- Gemfile
+-- module.gemspec
+-- Rakefile
```

The config.yml file contains the meta data of the module as well as a list of the other modules it depends on. 

The automations directory contains the actual automation scripts and the resource_automations directory contains the resource automation scripts. For each of these scripts a meta file must exist that contains (you guessed it right) the meta data of the automation script.

You can optionally include a Gemfile to your module. This will make sure that the versions of the modules (and other gems) that your module depends on are pinned during the installation of your module, even if more recent versions of these dependencies are installed later on. If you include a Gemfile.lock to the module (automatically generated when you do a 'bundle install') you can even pin these versions during build time. This will make sure that your module uses the same versions of the dependencies wherever and whenever it is installed. If you don't include any of these files then the latest available version of the dependent modules is automatically used.      

See the example files from the module_template directory for more information on the mandatory and optional fields.

In order to publish your module, two more files are needed: a module.gemspec file and a Rakefile. These files can be copied from the module_template directory unmodified.

During the development life cycle, after you have committed the changes to your automation scripts and bumped the version number from the config.yml file, you can now publish the new version of your module with a simple command:
```shell
rake release
```
 
By default the module will be published to the public rubygems.org repository. It is also possible however to publish your module to a [private repository](http://guides.rubygems.org/run-your-own-gem-server/) like [geminabox](https://github.com/geminabox/geminabox). See this [Rakefile](https://github.com/BMC-RLM/brpm_content_framework/blob/master/infrastructure/module_template/Rakefile_for_private_gem_repo) for an example of this alternative. In this case you should not forget to add your private sem server as a source on the gem environment of the BRPM instance:
```shell
gem sources -a http://your-private-gem-server:9292/
```

You can simply execute (or debug if your ruby IDE supports it, e.g. RubyMine) the scripts on your development machine. See further the section on Testability.

See the [recorded demo](https://youtu.be/08NuePJakGE) for a step-by-step explanation on how you can easily create your own module.

 
## Re-usability

### Automation scripts

Although the initial purpose of the BRPM Content framework is to exist on top of BRPM, it is perfectly possible to use it outside of BRPM. Let's say that you initially developed an automation script for usage within BRPM but now you need to run it from Jenkins, a shell script, or even a unit test? As the framework is highly decoupled from BRPM nothing prevents you from doing this.

As an example, see here how the create_package automation script from the bladelogic module can be executed in stand-alone mode:                                                                                                                                                                                                                                                                                                                                                                                               

```ruby
#!/usr/bin/env ruby
# Load the BRPM Content framework's script executor
require "brpm_script_executor"

# Supply the input parameters for the automation script, if any
params = {}
params["application"] = ENV["APPLICATION"]
params["component"] = ENV["COMPONENT"]
params["component_version"] = ENV["COMPONENT_VERSION"]

params["brpm_url"] = "http://#{ENV["BRPM_HOST"]}:#{ENV["BRPM_PORT"]}/brpm"
params["brpm_api_token"] = ENV["BRPM_TOKEN"]

params["SS_integration_dns"] = ENV["SS_INTEGRATION_DNS"]
params["SS_integration_username"] = ENV["SS_INTEGRATION_USERNAME"]
params["SS_integration_password"] = ENV["SS_INTEGRATION_PASSWORD"]
params["SS_integration_details"] = {}
params["SS_integration_details"]["role"] = ENV["SS_INTEGRATION_DETAILS_ROLE"]

params["log_file"] = ENV["LOG_FILE"]
params["also_log_to_console"] = "true"

# Execute the automation script
BrpmScriptExecutor.execute_automation_script("brpm_module_bladelogic", "create_package", params)
```
[source](https://github.com/BMC-RLM/brpm_module_bladelogic/blob/master/bin/create_bl_package)

### Libraries

It is also possible to re-use the module's libraries in stand-alone mode:

```ruby
# Load the BRPM Content framework 
require "brpm_auto"

# Set up the framework and load the brpm module
BrpmAuto.setup()
BrpmAuto.require_module "brpm_module_brpm"

# Create a BRPM REST client and find all requests for application E-Finance
@brpm_rest_client = BrpmRestClient.new("http://my-brpm-server/brpm', "<api token>")

app = @brpm_rest_client.get_app_by_name("E-Finance")
requests = @brpm_rest_client.get_requests_by({ "app_id" => app["id"]})
```

## Testability

Thanks to the decoupling between the BRPM Content framework and BRPM itself, it is very straightforward to write automated tests for the automation logic that runs on top of the framework.
 
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
      BrpmScriptExecutor.execute_automation_script("brpm_module_brpm", "create_release_request", params)

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
[source](https://github.com/BMC-RLM/brpm_module_brpm/blob/master/tests/create_release_request_spec.rb#L28)

The framework itself comes with a set of [RSpec tests](https://github.com/BMC-RLM/brpm_content_framework/tree/master/tests) that are executed automatically by [Travis CI](https://travis-ci.org/) after each commit of code changes. The status can be consulted on top of this page.

## Framework
### Dependency management

If you want to use a library or automation script from a different module you can indicate a dependency to that module in your own module's config.yml file. This will automatically install all directly and indirectly depending modules during the installation as well as make their libraries available to the scripts in your own module. No need to manage the 'require' statements for these libraries yourself.

You can also pin the dependency to a specific version of a module. This can be useful in situations where multiple people of teams share the same modules and one team wants to upgrade to a new version of the depending module but the other teams don't want to risk breaking their own automations due to backward compatibilities that may have crept into the new version. 

When multiple versions of a module are needed they can simply be installed side-by-side. This will happen automatically when the modules are installed as dependencies of other modules, but you can also indicate the version number when you install a module explicitly:
```shell
brpm_install brpm_module_brpm 1.2.3
```

When you link a request's step to an automation script can can optionally indicate the version number of the module (and even the framework). If no version number is specified then automatically the latest installed version will be used.

### Parameters

The framework parses the input parameters it receives from the caller and stores them into an easy to use structure for usage by the automation scripts.

#### input params

Input params are the regular parameters that are received from the caller.

They can be used as following:
```ruby
application = BrpmAuto.params.application

my_custom_param = BrpmAuto.params["my_custom_param"]
```

Check out the [automated tests](https://github.com/BMC-RLM/brpm_content_framework/blob/master/tests/params_spec.rb) for more complex use cases.

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

Check out the [automated tests](https://github.com/BMC-RLM/brpm_content_framework/blob/master/tests/request_params_spec.rb) for more complex use cases.

#### integration settings

The integration settings are the connection parameters that are needed to connect with the integration server that was defined for the automation script in BRPM. They are stored as part of the input params.

### Logging

You can use the built-in logging feature for any logging needs. The logs will be visible on the 'Notes' tab of the associated BRPM step after the automation is finished. You can also consult the logs in real-time by navigating to http://my_brpm_server/brpm/automation_results/log.html?request=request id

Example:
```ruby
BrpmAuto.log "Hello World"
```

### Error handling

Any ruby exception that is not trapped inside the automation scripts will cause the associated BRPM step to transition into problem state. This is also the only way to force the step into a problem state. If no exception is thrown the step will always be considered successful and the request will continue.

### Extensions

#### server yaml file

The framework allows you to define your own parameters that will automatically be made available to all automation scripts. You can do this by creating a file server.yml in $BRPM_HOME/config and adding your parameters into it, in YAML format. See [here](https://github.com/BMC-RLM/brpm_content_framework/blob/master/infrastructure/config/server.yml) for an example. 

#### customer include file

The framework allows you to create your own ruby methods that you will automatically be able to use in all automation scripts. You can do this by creating a file customer_include.rb in $BRPM_HOME/config and adding your custom methods into it. See [here](https://github.com/BMC-RLM/brpm_content_framework/blob/master/infrastructure/config/customer_include.rb) for an example.

Note
If a get_customer_include_params method exists, the framework will automatically execute it and add the resulting hash into the parameters hash.

This feature is deprecated. Consider creating a server.yml file for storing customer-specific parameters or creating a module for re-using customer-specific logic. 

### Other framework features
#### Execute command
#### Semaphores

## Integrations

The BRPM Content framework makes it easy to integrate with other tools using web hook and messaging technology. In both cases it is possible to execute an automation script (or use a library) whenever a notification is received.

### Web hook receivers

The framework contains a generic [web hook receiver script](https://github.com/BMC-RLM/brpm_content_framework/blob/master/bin/webhook_receiver) with an associated [bash wrapper script](https://github.com/BMC-RLM/brpm_content_framework/blob/master/infrastructure/scripts/run_webhook_receiver.sh) that can be run as a daemon. You can pass it a custom script that can take care of processing the received events. Typically this event processing script will then execute the appropriate automation scripts.
 
A web hook receiver solution can be used for synchronizing data that is owned by another system (assuming it supports web hooks) with BRPM.

For an example of how to synchronize JIRA issues with BRPM tickets see the [web hook receiver script](https://github.com/BMC-RLM/brp_module_demo/lib/integrations/jira/process_webhook_event.rb) that could be used for this purpose. As soon as the script is run in daemon mode (and JIRA is configured to send event notifications to a web hook) it will start receiving events when issues are created or updated. 

### Messaging engine

BRPM comes with a messaging engine that can send a notification for many events like the creation or update or requests, plans etc. The framework contains an [event handler script](https://github.com/BMC-RLM/brpm_content_framework/blob/master/bin/event_handler) with an associated [bash wrapper script](https://github.com/BMC-RLM/brpm_content_framework/blob/master/infrastructure/scripts/run_event_handler.sh) that can be set up to listen to these incoming events. You can pass it a custom script that can take care of processing the received events. Typically this event processing script will then execute the appropriate automation scripts.

A messaging solution can be used for extending the out-of-the-box BRPM feature set or for synchronizing BRPM owned data with other systems. 

For an example of how to update the status of the associated JIRA tickets after a deployment request finished successfully see the [event handler script](https://github.com/BMC-RLM/brpm_module_demo/integrations/brpm/process_event_handler_event.rb) (search for update_tickets_in_jira_by_request) that could be used for this purpose. As soon as the script is run in daemon mode it will start receiving events when requests change status. 

## Publicly available modules:
### [BRPM](https://github.com/BMC-RLM/brpm_module_brpm)   
### [Bladelogic](https://github.com/BMC-RLM/brpm_module_bladelogic)
### [JIRA](https://github.com/BMC-RLM/brpm_module_jira)
### [Jenkins](https://github.com/BMC-RLM/brpm_module_jenkins)
### [Demo customer](https://github.com/BMC-RLM/brpm_module_demo)

