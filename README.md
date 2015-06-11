# BRPM Content

[![Build Status](https://travis-ci.org/BMC-RLM/brpm_content.svg?branch=master)](https://travis-ci.org/BMC-RLM/brpm_content)

## Installation

First of all, make sure that the environment variable BRPM_HOME is set to the location where BRPM is installed, e.g. /opt/bmc/RLM:
```shell
export BRPM_HOME=/opt/bmc/RLM
```

Then copy the installation script to the instance on which BRPM is installed and execute it:
```shell
wget https://raw.githubusercontent.com/BMC-RLM/brpm_content/master/infrastructure/shell_scripts/install_content_repo.sh
chmod +x install_content_repo.sh
./chmod +x install_content_repo.sh
```

The script will ask for the location of a zip file that contains the files. If the box has access to the internet you can leave it empty in which case it will directly grab the files from this github.com repo.
You can find the zip file on [https://github.com/BMC-RLM/brpm_content/archive/master.zip](https://github.com/BMC-RLM/brpm_content/archive/master.zip)

At this early stage it is still necessary to manually configure the automation scripts that come with this content repository in BRPM before you can start using them in the request steps. 

This can be done as following:
 - go to Environment > Automation and create an automation script
 - choose the type and category of the automation script
 - paste the content of the automation script's wrapper file (the file with the same name as the automation script but with the .txt extension) into the script body
 
The above remark applies to both automation scripts as well as resource automation scripts
 
Finally, make sure that the following item is added to Metadata > Lists > AutomationErrors: '******** ERROR ********'. This will allow non caught exceptions from the automation scripts to cause the step to go in problem mode.

## Architecture
![alt text](https://github.com/BMC-RLM/brpm_content/blob/master/architecture.png "architecture")

## Modularity

Phase 2: all modules will be maintained in dedicated github (or other) repositories

## Framework
### Dependency management
### Parameters
#### input params
#### request params
#### integration settings
### Logging
### Error handling
### Other framework features
#### execute command
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

## External modules

External modules are modules that are not part of this repository. They can be developed by anyone who may have an interest in creating and sharing one or a set of automation scripts.
 
The file structure of a module is very simple: just create a directory automations (or resource_automations) in the root of the repo and put the automation scripts in there. As a convention you can store libraries in the lib directory and tests in the tests directory. For an example see the Selenium module.

External modules can be installed by executing the installation script: 
```shell
~/shell_scripts/install_content_module.sh
```

The script will ask for the location of a zip file or the url of a github.com repository that contains the module's files, e.g. [https://github.com/BMC-RLM/brpm_module_selenium](https://github.com/BMC-RLM/brpm_module_selenium).

### [Selenium](https://github.com/BMC-RLM/brpm_module_selenium) (in progress)

