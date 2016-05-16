# Copyright 2012 Trustees of FreeBMD
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 
MyopicVicar::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  if config.respond_to?(:action_mailer)
    config.action_mailer.raise_delivery_errors = false
  end

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  
  # Do not compress assets
  config.assets.compress = false
   
  # Expands the lines which load the assets
  config.assets.debug = false
  config.assets.raise_runtime_errors = true


  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict
   
  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5
  #where to store the collections PlaceChurch
  config.mongodb_collection_temp = File.join(Rails.root,'tmp')
  #Where the collections are stored
  config.mongodb_collection_location = File.join(Rails.root,'db','collections')
  # Date of dataset used
  config.dataset_date = "9 November 2014"

  config.mongodb_bin_location = MyopicVicar::MongoConfig['mongodb_bin_location']
  config.datafiles = MyopicVicar::MongoConfig['datafiles']
  config.dataset_date =  MyopicVicar::MongoConfig['dataset_date'] unless MyopicVicar::MongoConfig['dataset_date'].blank?
  config.datafiles_changeset = MyopicVicar::MongoConfig['datafiles_changeset'] unless MyopicVicar::MongoConfig['datafiles_changeset'].blank?
  config.datafiles_delta = MyopicVicar::MongoConfig['datafiles_delta'] unless MyopicVicar::MongoConfig['datafiles_delta'].blank?
  config.website = MyopicVicar::MongoConfig['website']
  config.backup_directory = MyopicVicar::MongoConfig['backup_directory']
  config.github_login = 'FreeUKGenIssues'
  config.github_password = ENV["GITHUB_WORD"]
  config.github_repo = 'FreeUKGen/FreeCENMigration'
  config.days_to_retain_search_queries = 90
  config.sleep = MyopicVicar::MongoConfig['sleep']
  config.processing_delta = MyopicVicar::MongoConfig['files_for_processing'] unless MyopicVicar::MongoConfig['files_for_processing'].blank?
  config.delete_list = MyopicVicar::MongoConfig['delete_list']
  config.member_open = MyopicVicar::MongoConfig['member_open']
  config.fc1_coverage_stats = MyopicVicar::MongoConfig['fc1_coverage_stats']
end
