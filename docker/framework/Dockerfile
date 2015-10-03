FROM atlashealth/ruby:1.9.3
MAINTAINER Niek Bartholomeus <niek.bartholomeus@gmail.com>

ENV GEM_HOME /usr/lib/ruby/gems/1.9.1
ENV VERSION 1.0.0

RUN gem install brpm_content_framework -v $VERSION && \
    cd $GEM_HOME/gems/brpm_content_framework-$VERSION && \
    bundle install && \
    rm -rf $GEM_HOME/cache

ADD . /

VOLUME [ "/workdir" ]
VOLUME [ "/automation_results" ]
VOLUME [ "/script_support" ]
