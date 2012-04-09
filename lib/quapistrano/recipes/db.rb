require 'quapistrano/helper'

Capistrano::Configuration.instance(true).load do
  _cset :backup_dir,            "#{shared_dir}/backup"
  
  _cset :mysqldump_bin,         "mysqldump"
  
  _cset :db_backup_count,       5
  
  _cset (:backup_path)          { File.join(deploy_to, backup_dir) }
  _cset (:db_backup_dir)        { File.join(backup_dir, 'db') }
  _cset (:db_backup_path)       { File.join(deploy_to, db_backup_dir) }
  
  
  _cset :db_backup_local_dir,  "db/backup"
  
  
  after 'deploy:setup' do
    db.local.setup
    db.remote.setup
  end
  
  after 'deploy:cleanup' do
    db.remote.cleanup
  end
  
  before 'deploy:migrate' do
    db.remote.backup
  end
  
  def db_config(environment = rails_env)
    @db_config ||= db_config_fetch
    return @db_config[environment]['username'], @db_config[environment]['password'], @db_config[environment]['database'], @db_config[environment]['adapter']
  end
    
  def db_config_fetch
    require 'yaml'
    YAML::load_file("config/database.yml")
  end
  
  def db_backup_filename
    @db_backup_filename ||= "#{db_backup_filename_base}.#{Time.now.strftime '%Y%m%d%H%M%S'}.sql.bz2"
  end
  
  def db_backup_filename_base
    "database.#{rails_env}"
  end
    
  def db_backup_mysql_cmd(username, password, database)
    "mysqldump --opt -u #{username} --password=#{password} #{database}"
  end
  
  def db_output_and_compress cmd, filename
    "#{cmd} | bzip2 -9 > #{filename}"
  end
  
  def db_restore_mysql_cmd(username, password, database, file_to_restore)
    "bunzip2 --stdout #{file_to_restore} | mysql -u #{username} --password=#{password} #{database}"
  end
  
  def db_create_database_mysql_cmd(username, password, database)
    sql = "CREATE DATABASE #{database};"
    "mysql -u #{username} --password=#{password} --execute=\"#{sql}\""
  end
    
  def db_backup_cmd filename_to_backup
    username, password, database, adapter = db_config
    db_output_and_compress db_backup_mysql_cmd(username, password, database), filename_to_backup
  end
  
  def db_restore_cmd file_to_restore
    username, password, database, adapter = db_config
    db_restore_mysql_cmd(username, password, database, file_to_restore)
  end
  
  def db_create_database_cmd
    username, password, database, adapter = db_config
    db_create_database_mysql_cmd(username, password, database)
  end
  
  namespace :db do
    namespace :local do
      
      desc "Simply calls local backup"
      task :default do
        db.local.backup
      end
      
      desc "Runs a local db backup"
      task :backup, :roles => :db, :only => { :primary => true } do
        run_locally db_backup_cmd File.join(db_backup_path, db_backup_filename)
      end
      
      desc "Restores the DB based on the last updated file in the db backup local dir"
      task :restore, :roles => :db, :only => { :primary => true } do
        file_to_restore = run_locally("ls -xt #{db_backup_local_dir}/#{db_backup_filename_base}*").split.take(1).first
        run_locally db_restore_cmd file_to_restore unless file_to_restore.nil?
      end
      
      desc "Locally purges old backups"
      task :cleanup, :roles => :db, :only => { :primary => true } do
        files_to_remove = run_locally("ls -xt #{db_backup_local_dir}/#{db_backup_filename_base}*").split.drop(db_backup_count.to_i).join(" ")
        run_locally "rm #{files_to_remove}" unless files_to_remove.nil? or files_to_remove.length == 0
      end
      
      desc "Syncs local database with remote database"
      task :sync, :roles => :db, :only => { :primary => true } do
        db.remote.download
        db.local.restore
      end
      
      desc "Creates local backup dir"
      task :setup, :roles => :db, :only => { :primary => true } do
        run_locally "mkdir -p #{db_backup_local_dir}"
      end
    end
    
    namespace :remote do
      desc "Simply calls remote backup"
      task :default do
        db.remote.backup
      end
      
      task :create_database, :roles => :db do
        username, password, database, adapter = db_config
        run db_create_database_cmd
      end
      
      desc "Backs up the remote DB"
      task :backup, :roles => :db, :only => { :primary => true } do
        run db_backup_cmd File.join(db_backup_path, db_backup_filename)
      end

      desc "Restores the remote DB based on the last updated file in remote db backups dir"
      task :restore, :roles => :db, :only => { :primary => true } do
        file_to_restore = capture("ls -xt #{db_backup_path}/#{db_backup_filename_base}*").split.take(1).first
        run db_restore_cmd file_to_restore unless file_to_restore.nil?
      end

      desc "Downloads the current db into the local backup dir (also remotely backs up the DB)"
      task :download, :roles => :db, :only => { :primary => true } do
        run db_backup_cmd File.join(db_backup_path, db_backup_filename)
        get File.join(db_backup_path, db_backup_filename), File.join(db_backup_local_dir, db_backup_filename)
      end
      
      desc "Uploads the DB dumps in local backup dir"
      task :upload, :roles => :db, :only => { :primary => true } do
        file_to_upload = run_locally("ls -xt #{db_backup_local_dir} | head -n 1").strip.chomp
        put File.read(File.join Dir.getwd, db_backup_local_dir, file_to_upload), File.join(db_backup_path, file_to_upload) unless file_to_upload.nil? or file_to_upload.length == 0
      end
      
      desc "Creates a local db backup and syncs remote with the backup"
      task :sync, :roles => :db, :only => { :primary => true } do
        db.local.backup
        db.remote.upload
        db.remote.restore
      end
      
      desc "Purges old backup files"
      task :cleanup, :roles => :db, :only => { :primary => true } do
        files_to_remove = capture("ls -xt #{db_backup_path}/#{db_backup_filename_base}*").split.drop(db_backup_count.to_i).join(" ")
        run "#{try_sudo} rm #{files_to_remove}" unless files_to_remove.nil? or files_to_remove.length == 0
      end

      desc "Creates the backup file"
      task :setup, :roles => :db, :only => { :primary => true } do
        run "#{try_sudo} mkdir -p #{db_backup_path}"
      end
    end
  end
end