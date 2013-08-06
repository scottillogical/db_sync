require 'spec_helper'

class Article < ActiveRecord::Base
end

describe "db_sync" do 
  before do 
    Article.delete_all
    DbSync.configure do |config|
      config.sync_tables = [:articles]
    end
  end

  let!(:article) do 
    Article.create(title: "test")
  end

  it "dumps" do 
    DbSync.dump_data
  end

  it "loads" do 
    Article.delete_all
    DbSync.load_data
    Article.find_by_title(article.title).should_not be_nil
  end

end
