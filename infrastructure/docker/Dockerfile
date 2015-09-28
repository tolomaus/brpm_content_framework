FROM atlashealth/ruby:1.9.3
MAINTAINER Niek Bartholomeus <niek.bartholomeus@gmail.com>

ENV BRPM_CONTENT_FRAMEWORK_VERSION 0.2.24

RUN gem install brpm_content_framework --ignore-dependencies -v $BRPM_CONTENT_FRAMEWORK_VERSION
RUN cd /usr/lib/ruby/gems/1.9.1/gems/brpm_content_framework-$BRPM_CONTENT_FRAMEWORK_VERSION && bundle install

ADD . /