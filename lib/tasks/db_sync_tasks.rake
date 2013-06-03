namespace :db_sync do
  desc "Dump specific tables from configuration into db/data"
  task :dump_data => :environment do
    DbSync.dump_data
    puts 'Dump succeeded'
  end

  desc "Load data from db/data, overwriting the existing tables"
  task :load_data => :environment do
    DbSync.load_data
    puts "Loaded data"
  end
end

