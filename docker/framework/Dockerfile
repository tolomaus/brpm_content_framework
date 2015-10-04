FROM atlashealth/ruby:1.9.3
MAINTAINER Niek Bartholomeus <niek.bartholomeus@gmail.com>

ENV GEM_HOME /usr/lib/ruby/gems/1.9.1
ENV MODULE brpm_content_framework
ENV VERSION 1.0.0

COPY install_gem.sh /
RUN /install_gem.sh

COPY docker_execute_automation /

VOLUME [ "/workdir" ]
VOLUME [ "/automation_results" ]
VOLUME [ "/script_support" ]
