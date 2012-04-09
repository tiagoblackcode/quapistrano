require 'quapistrano/helper'

Capistrano::Configuration.instance(true).load do
    
  _cset :shared_folders, {
    'uploads' => 'public/uploads'
  }
  
  after 'deploy:setup' do
    shared.remote.setup
  end
  
  after 'deploy:update' do
    shared.remote.symlink
  end
  
  namespace :shared do
    namespace :remote do
      
      desc "Creates the shared folders under shared_path' "
      task :setup, :roles => :app, :except => { :no_release => true } do
        run shared_folders.map { |from, _| "#{try_sudo} mkdir -p #{shared_path}/#{from}" }.join( ' && ')
      end

      desc "Creates the symlink between the shared folders and the release path"
      task :symlink, :roles => :app, :except => { :no_release => true } do
        run shared_folders.map { |from, to| "#{try_sudo} ln -is #{shared_path}/#{from} #{current_path}/#{to}" }.join(' && ')
      end
      
      desc "Syncs the remote shared folders with the local ones"
      task :sync, :roles => :app, :except => { :no_release => true } do
        run_locally shared_folders.map { |from, to| roles[:app].map { |role| "rsync -vr --exclude='.DS_Store' #{File.expand_path(to)} #{user}@#{role}:#{File.expand_path(File.join(shared_path,from, '..'))}" }.join(' && ') }.join(' && ')
      end
    end
    
    namespace :local do
      desc "Syncs the local shared folders with the remote ones"
      task :sync, :roles => :app, :except => { :no_release => true } do
        run_locally shared_folders.map { |from, to| "rsync -vr --exclude='.DS_Store' #{user}@#{roles[:app].to_ary.first}:#{shared_path}/#{from} #{File.expand_path(File.join(to, '..'))}" }.join(' && ')
      end
    end
  end
end