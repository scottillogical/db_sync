# DbSync
This gem is for exporting and importing data from different databases.

Recommended use is for syncing certain tables from production into development for testing.

It exports specified tables into yaml stored in db/data.

## Installation

Add this line to your application's Gemfile:

    gem 'db_sync'


And in config/initializers/db_sync.rb

    DbSync.configure do |config|
      config.sync_tables = ["TABLE_NAME"]
    end

## Usage 

Run this to dump the tables you specified in the initializer to db/data
   
    bundle exec rake db_sync:dump_data 

Run this to load the tables back in.
WARNING: this overwrites the contents of this existing table.  
   
    bundle exec rake db_sync:load_data

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
