module Helpers
  module Common
    def say msg
      Capistrano::CLI.ui.say(msg)
    end
    
    def join_cmds *cmds
      cmds.join(' && ')
    end
   
    def _cset(variable, *args, &block)
      set(variable, *args, &block) unless exists?(variable)
    end
    
    def try_bundle
      defined?(Bundler) ? "bundle exec" : ""
    end
    
    def is_using_nginx
      is_using('nginx',:web_server)
    end

    def is_using_unicorn
      is_using('unicorn',:app_server)
    end

    def is_using(something, with_some_var)
     exists?(with_some_var.to_sym) && fetch(with_some_var.to_sym).to_s.downcase == something
    end
  end
end