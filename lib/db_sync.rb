require "db_sync/version"
require 'db_sync/railtie' if defined?(Rails)
module DbSync

  class Configuration
    attr_accessor :sync_tables

    def initializers
      sync_tables = []
    end
  end

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration) if block_given?
  end

  def self.dump_data
    DbSync.configuration.sync_tables.each do |table_name|    
      location = FileUtils.mkdir_p "#{Rails.root}/db/data"    
      i = "000"    
      sql  = "SELECT * FROM %s"    
      File.open("#{location.first}/#{table_name}.yml", 'w') do |file|      
        data = ActiveRecord::Base.connection.select_all(sql % table_name.upcase)      
        file.write data.inject({}) { |hash, record|  
          hash["#{table_name}_#{i.succ!}"] = record        
          hash      
        }.to_yaml      
        puts "wrote #{file.path} /"    
      end  
    end
  end

  def self.load_data
    require 'active_record/fixtures'  
    base_dir     = "#{Rails.root}/db/data"  
    fixtures_dir = File.join [base_dir, ENV['FIXTURES_DIR']].compact  
    fixture_files = (ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/) : Dir["#{fixtures_dir}/**/*.{yml,csv}"].map {|f| f[(fixtures_dir.size + 1)..-5] })
    fixture_files.each do |fixture_file|    
      ActiveRecord::Fixtures.create_fixtures(fixtures_dir, fixture_file)  
    end
  end
end
