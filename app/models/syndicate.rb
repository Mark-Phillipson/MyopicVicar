class Syndicate
  include Mongoid::Document
  include Mongoid::Timestamps::Created::Short
  include Mongoid::Timestamps::Updated::Short

  field :syndicate_code, type: String
  field :syndicate_coordinator, type: String
   field :syndicate_coordinator_lower_case, type: String
  field :previous_syndicate_coordinator, type: String
  field :syndicate_description, type: String
  field :syndicate_notes, type: String
  before_save :add_lower_case_and_change_userid_fields

 index ({ syndicate_code: 1, syndicate_coordinator: 1 })
 index ({ syndicate_coordinator: 1 })
index ({ sprevious_syndicate_coordinator: 1 })

def  add_lower_case_and_change_userid_fields
   self.syndicate_coordinator_lower_case = self.syndicate_coordinator.downcase
  
  @old_userid = UseridDetail.where(:userid => self.previous_syndicate_coordinator).first 
  @new_userid = UseridDetail.where(:userid => self.syndicate_coordinator).first

  unless @old_userid.nil? then

     if @old_userid.syndicate_groups.length == 1 then
       @old_userid.person_role = 'transcriber'  unless (@old_userid.person_role == 'county_coordinator' || @old_userid.person_role == 'country_coordinator' || @old_userid.person_role == 'system_adminstrator' || @old_userid.person_role == 'volunteer_coordinator')
     end 

    @old_userid.syndicate_groups.delete_if {|code| code == self.syndicate_code}
  end
 
    if @new_userid.syndicate_groups.length == 0 then
     @new_userid.person_role = 'syndicate_coordinator' if (@new_userid.person_role == 'transcriber' || @new_userid.person_role == 'researcher')
    end 
   @new_userid.syndicate_groups << self.syndicate_code
  
   @old_userid.save!  unless @old_userid.nil?
   @new_userid.save!

end


end
