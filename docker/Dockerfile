FROM atlashealth/ruby:1.9.3
MAINTAINER Niek Bartholomeus <niek.bartholomeus@gmail.com>

ENV BRPM_CONTENT_FRAMEWORK_VERSION 1.0.0
ENV GEM_HOME /usr/lib/ruby/gems/1.9.1

RUN gem install brpm_content_framework -v $BRPM_CONTENT_FRAMEWORK_VERSION && \
    cd $GEM_HOME/gems/brpm_content_framework-$BRPM_CONTENT_FRAMEWORK_VERSION && \
    bundle install && \
    rm -rf $GEM_HOME/cache

ADD . /

VOLUME [ "/workdir" ]
VOLUME [ "/automation_results" ]
VOLUME [ "/script_support" ]
