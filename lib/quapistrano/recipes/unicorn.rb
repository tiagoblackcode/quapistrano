require 'quapistrano/helper'

Capistrano::Configuration.instance(true).load do
  _cset :rails_env,         "production"
  
  _cset :unicorn_bin,       "#{try_bundle} unicorn_rails"
  _cset :unicorn_config,    "config/unicorn.rb"

  _cset :pid_dir,           "#{shared_dir}/pids"
  _cset :socket_dir,        "#{shared_dir}/sockets"
  
  _cset (:pids_path)         { File.join(deploy_to, pid_dir) }
  _cset (:sockets_path)      { File.join(deploy_to, socket_dir) }
  
  _cset (:unicorn_socket)    { File.join(sockets_path, 'unicorn.sock') }
  _cset (:unicorn_pid)       { File.join(pids_path, 'unicorn.pid') }
  
  
  after 'deploy:setup' do
    unicorn.setup
  end
  
  namespace :deploy do
    task :restart do
      unicorn.restart
    end
  end
  
  
  def unicorn_start_cmd
    "cd #{current_path} && #{unicorn_bin} -c #{unicorn_config} -E #{rails_env} -D"
  end
  
  def unicorn_stop_cmd
    "cd #{current_path} && kill -QUIT `cat #{unicorn_pid}`"
  end
  
  def unicorn_reload_cmd
    "cd #{current_path} && kill -USR2 `cat #{unicorn_pid}`"
  end
  
  def unicorn_status_cmd
    "if [ -f #{unicorn_pid} ]; then ps -Afu #{user} | grep `cat #{unicorn_pid}` | grep -v grep; fi"
  end
  
  def unicorn_setup_cmd
    join_cmds "mkdir -p #{sockets_path}", "chown -R #{user} #{sockets_path}", "chmod +rw #{sockets_path}"
  end
  
  def unicorn_restart_cmd
    join_cmds unicorn_stop_cmd, unicorn_start_cmd
  end
  
  namespace :unicorn do
    desc "Starts an unicorn daemon using provided unicorn's configuration file and rails environment"
    task :start, :roles => :app do
      run unicorn_start_cmd
    end
    
    desc "Stops the unicorn daemon pointed by the pid file"
    task :stop, :roles => :app do
      run unicorn_stop_cmd
    end
    
    desc "Makes unicorn reload the rails application"
    task :reload, :roles => :app do
      run unicorn_reload_cmd
    end   
    
    desc "Restarts unicorn daemon so that new updates are reflected"
    task :restart, :roles => :app do
      run unicorn_restart_cmd
    end
    
    desc "List the unicorn processes running"
    task :status, :roles => :app do
      text = []
      run unicorn_status_cmd { |_,_,data| text << data }
      text.join('').lines.each { |line| logger.info(line) }
    end
    
    desc "Creates a folder to place the socket file"
    task :setup, :roles => :app do
      run unicorn_setup_cmd
    end
  end
  
end