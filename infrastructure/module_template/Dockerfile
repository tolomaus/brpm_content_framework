FROM BMC-RLM/brpm_content_framework
MAINTAINER Niek Bartholomeus

ENV MODULE brpm_module_brpm
ENV VERSION 0.1.34

RUN gem install $MODULE -v $VERSION
#RUN if gemfile exists: cd <gemfile dir> && bundle install

VOLUME [ "/workdir" ]

ADD . /
