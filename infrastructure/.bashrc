export BRPM_HOME=/opt/bmc/RLM
export JAVA_HOME="$BRPM_HOME/lib/jre"
export JRUBY_HOME="$BRPM_HOME/lib/jruby"
export GEM_HOME=${BRPM_CONTENT_HOME:-$BRPM_HOME/modules}

export PATH="$GEM_HOME/bin:$JRUBY_HOME/bin:$PATH"
