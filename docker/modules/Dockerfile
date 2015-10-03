FROM bmcrlm/brpm_content_framework
MAINTAINER Niek Bartholomeus <niek.bartholomeus@gmail.com>

ENV MODULE module
ENV VERSION 1.0.0

RUN gem install $MODULE -v $VERSION && \
    cd $GEM_HOME/gems/$MODULE-$VERSION && \
    bundle install && \
    rm -rf $GEM_HOME/cache
