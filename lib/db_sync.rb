require "db_sync/version"
require 'db_sync/railtie' if defined?(Rails)
# YAML::ENGINE.yamler = "psych"
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
      location = FileUtils.mkdir_p File.join(Rails.root, 'db', 'data')
      i = "000"
      sql  = "SELECT * FROM %s"
      File.open("#{location.first}/#{table_name}.yml", 'w') do |file|
        data = ActiveRecord::Base.connection.select_all(sql % table_name)
        file.write data.inject({}) { |hash, record|
          hash["#{table_name}_#{i.succ!}"] = record
          hash
        }.to_yaml
        puts "wrote #{file.path} /"
      end
    end
  end

  def self.load_data
    Dir["#{Rails.root}/db/data/*{yml}"].each do |data_file|
      load_document(data_file)
    end
  end

  def self.load_document(filename)
    YAML.load_stream(File.new(Rails.root.join(filename), "r").read).each do |row|
      columns =  row.values.first.map { |v| v[0]}
      values = row.values.first.map { |v| ActiveRecord::Base.connection.quote(v[1])}
      table_name = File.basename(filename).split(".").first

      # This assumes the first attribute (typically id) is unique and only the unique restraint
      sql = "INSERT INTO #{table_name} (#{columns.join(',')}) values (#{values.join(',')}) ON DUPLICATE KEY UPDATE #{columns.first}=#{values.first}"
      puts "SQL #{sql}"

      ActiveRecord::Base.connection.execute(sql)
    end
  end
end
