FROM bmcrlm/brpm_content_framework:<framework version>
MAINTAINER Niek Bartholomeus <niek.bartholomeus@gmail.com>

ENV MODULE <module name>
ENV VERSION <module version>

RUN gem install $MODULE --ignore-dependencies -v $VERSION
RUN cd $GEM_HOME/gems/$MODULE-$VERSION && bundle install

VOLUME [ "/workdir" ]

ADD . /
