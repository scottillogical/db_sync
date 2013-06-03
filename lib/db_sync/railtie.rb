module DbSync
  class Railtie < ::Rails::Railtie
    rake_tasks do
      load "tasks/db_sync_tasks.rake"
    end
  end
end

