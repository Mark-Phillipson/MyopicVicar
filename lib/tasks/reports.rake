namespace :reports do
	
desc "Create a missing locations list"
 # eg foo:create_search_records_docs[rebuild,e:/csvaug/a*/*.csv]
 #valid options for type are rebuild, replace, add
 task :missing_locations, [:limit] => [:environment] do |t, args|
 require 'missing_locations' 
 
  Mongoid.unit_of_work(disable: :all) do
   
     
          MissingLocations.process(args.limit) 
          
     
    puts "Task complete."
   end
  end

desc "Create a report of files loaded by people"
 # eg foo:create_search_records_docs[rebuild,e:/csvaug/a*/*.csv]
 #valid options for type are rebuild, replace, add
 task :userid_files, [:syndicate] => [:environment] do |t, args|
 require 'userids_files' 
 
  Mongoid.unit_of_work(disable: :all) do
   
     
          UseridsFiles.process(args.syndicate) 
          
     
    puts "Task complete."
   end
  end

desc "Create a report of Master files"
 # eg foo:create_search_records_docs[rebuild,e:/csvaug/a*/*.csv]
 #valid options for type are rebuild, replace, add
 task :master_place_name_report, [:limit] => [:environment] do |t, args|
 require 'master_place_name_report' 
 
  Mongoid.unit_of_work(disable: :all) do
   
     
          MasterPlaceNameReport.process(args.limit) 
          
     
    puts "Task complete."
   end
  end




end