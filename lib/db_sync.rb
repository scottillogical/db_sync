require "db_sync/version"
require 'db_sync/railtie' if defined?(Rails)
module DbSync
  class Configuration
    attr_accessor :sync_tables, :db_data_folder

    def initialize
      @sync_tables = []
      @db_data_folder = File.join(Rails.root, 'db', 'data')
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
      location = FileUtils.mkdir_p DbSync.configuration.db_data_folder
      i = "000"
      sql  = "SELECT * FROM %s"
      File.open( File.join(location.first, "#{table_name}.yml"), 'w') do |file|
        data = ActiveRecord::Base.connection.select_all(sql % table_name)
        file.write data.inject({}) { |hash, record|
          hash["#{table_name}_#{i.succ!}"] = record
          hash
        }.to_yaml
        puts "wrote #{file.path} /"
      end
    end
  end

  # Useful for when importing tables with foreign key references that are enforced at the DB level
  def self.load_data_order
    DbSync.configuration.sync_tables.each do |table_name|
      file = File.join(DbSync.configuration.db_data_folder, "#{table_name}.yml")
      load_document( file )
    end
  end

  def self.load_data
    Dir[File.join(DbSync.configuration.db_data_folder, '*yml')].each do |file|
      load_document( file )
    end
  end

  def self.load_document(filename)
    table_name = File.basename(filename).split(".").first
    Psych.load_file(filename).each do |row|
      columns = row.last.map { |k,v| k }
      values = row.last.map { |k,v| ActiveRecord::Base.connection.quote(v) }

      # This assumes the first attribute (typically id) is unique and is the only unique restraint
      sql = "INSERT INTO #{table_name} (#{columns.join(',')}) values (#{values.join(',')}) ON DUPLICATE KEY UPDATE #{columns.first}=#{values.first}"
      ActiveRecord::Base.connection.execute(sql)
    end
  end
end
