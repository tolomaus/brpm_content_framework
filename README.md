# BRPM Content

[![Build Status](https://travis-ci.org/BMC-RLM/brpm_content.svg?branch=master)](https://travis-ci.org/BMC-RLM/brpm_content)

The BRPM Content framework is intended to make the creation and usage of content (for the moment limited to automation scripts) on top of BRPM as easy as possible.

It is designed around a number of core concepts like modularity, re-usability, testability that are further explained below.

## Installation

First of all, make sure that the environment variable BRPM_HOME is set to the location where BRPM is installed, e.g. /opt/bmc/RLM:
```shell
export BRPM_HOME=/opt/bmc/RLM
```

Then copy the installation script to the instance on which BRPM is installed and execute it, e.g.:
```shell
wget https://raw.githubusercontent.com/BMC-RLM/brpm_content/master/infrastructure/shell_scripts/install_content_repo.sh
chmod +x install_content_repo.sh
./install_content_repo.sh
```

The script will ask for the location of a zip file that contains the files. If the BRPM instance has access to the internet you can leave it empty in which case it will directly grab the files from this github.com repo.
If you need the zip file of this repo you can find it on [https://github.com/BMC-RLM/brpm_content/archive/master.zip](https://github.com/BMC-RLM/brpm_content/archive/master.zip)

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
![alt text](https://github.com/BMC-RLM/brpm_content/blob/master/architecture.png "architecture")

## Modularity

One of the core concept of the framework is its modularity. The framework itself is deliberately chosen to be very lightweight. The purpose is that all custom automation logic is added by means of modules. Modules will typically group multiple automation scripts, resource automation scripts and libraries of one specific domain and can be developed by anyone who may have an interest in creating and sharing automation logic.
 
The file structure of a module is very simple: 
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

For an example see the [Selenium](https://github.com/BMC-RLM/brpm_module_selenium) module.

Modules can be installed from a zip file or directly from a github repo. Just make sure that you follow the expected file structure. 

The installation itself can be done by executing the installation script: 
```shell
~/shell_scripts/install_content_module.sh
```

The script will ask for the location of a zip file or the url of a github.com repository that contains the module's files. For the Selenium module this url would be [https://github.com/BMC-RLM/brpm_module_selenium](https://github.com/BMC-RLM/brpm_module_selenium).

Note that the BRPM Content framework contains a number of core [modules](https://github.com/BMC-RLM/brpm_content/tree/master/modules) that will be installed by default. The purpose is to gradually move these built-in modules into their own dedicated github repositories.  

The config.yml file contains the integration server and any other modules it may depend on, both are optional. In the future it will also be possible to version modules. 

## Framework
### Dependency management

If you want to use a library or automation script from a different module you can indicate a dependency to that module in your own module's config.yml file. This will automatically make all libraries and automation modules available to all of the scripts in your own module. No need to add 'require' statements yourself.

### Parameters
#### input params
#### request params
#### integration settings
### Logging

You can use the built-in logging feature for any logging needs. The logs will be visible on the 'Notes' tab of the associated BRPM step after the automation is finished. You can also consult the logs in real-time by navigating to <BRPM server>brpm/automation_results/log.html?request=<request id>

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


## Testability

## Re-usability
### Automation scripts
### Libraries

## Integrations
### Web hook receivers
### Messaging engine

## Modules
### BRPM   
### BladeLogic
### JIRA
### Jenkins

### [Selenium](https://github.com/BMC-RLM/brpm_module_selenium) (in progress)

