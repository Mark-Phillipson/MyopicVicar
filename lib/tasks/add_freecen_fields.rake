namespace :freecen do

  desc 'Add fields to support statistics'
  task :add_freecen_fields => [:environment] do
    # Print the time before start the process
    start_time = Time.now
    p "Starting at #{start_time}"

    # Call the RefreshUcfList library class file with passing the model name as parameter
    FreecenPiece.no_timeout.each do |piece|
      piece.num_dwellings = piece.freecen_dwellings.count
      piece.save
    end
    Freecen1VldFile.no_timeout.each do |file|
      file.num_entries = file.freecen1_vld_entries.count
      file.save
    end

    p "Process finished"
    running_time = Time.now - start_time
    p "Running time #{running_time} "
  end
end
