require 'capistrano'
require 'capistrano/cli'
require 'quapistrano/support/common'

unless Capistrano::Configuration.respond_to?(:instance)
  abort "capistrano/ext/multistage requires Capistrano 2"
end

include Helpers::Common