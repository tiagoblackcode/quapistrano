def cap_file
  File.join(File.expand_path(File.join('..', 'templates', 'Capfile'), File.dirname(__FILE__)))
end