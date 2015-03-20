# Test helper
# Included by all test files (included by file)

# Set environment to 'test'
ENV['RACK_ENV'] = 'test'

# Require application, test framework
$LOAD_PATH.unshift(File.absolute_path(File.join(File.dirname(__FILE__), '../')))
require 'zephir_api'
require "minitest/autorun"

# == Test Database Setup
# Class for creating mock database table
class CreateFiledata < ActiveRecord::Migration
  def create
    create_table :zephir_filedata, id: false do |t|
      t.string :id, String
      t.text :metadata, :limit => 4294967295
      t.text :metadata_json, :limit => 4294967295
    end
  end
end

# Create mock data (running test database migration)
begin
  CreateFiledata.new.create
rescue ActiveRecord::StatementInvalid
  # Mock Table already exists (it's probably OK, so ignore)
  # Keeping this as exception handling instead of always refreshing
  # incase production data is used for testing. Will fail in that case.
end

# Load fixture handling
require 'active_record/fixtures' 
# Load the test data into the mock database
(ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/) : Dir.glob(File.join(ENV['APP_ROOT'], 'test', 'fixtures', '*.{yml,csv}'))).each do |fixture_file|
  ActiveRecord::FixtureSet.create_fixtures('test/fixtures', File.basename(fixture_file, '.*'))
end
