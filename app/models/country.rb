class Country
   include Mongoid::Document
  include Mongoid::Timestamps::Created::Short
  include Mongoid::Timestamps::Updated::Short

  field :country_code, type: String
  field :country_coordinator, type: String
   field :country_coordinator_lower_case, type: String
   field :previous_country_coordinator, type: String
  field :country_description, type: String
  field :country_notes, type: String
  field :counties_included, type: Array
 before_save :add_lower_case_and_change_userid_fields

 index ({ country_code: 1, country_coordinator: 1 })
   index ({ country_coordinator: 1 })
   index ({ previous_country_coordinator: 1 })
    index ({ country_coordinator_lower_case: 1})
    index ({ country_code: 1, country_coordinator_lower_case: 1 })
     index ({ country_code: 1, previous_country_coordinator: 1 })

     def  add_lower_case_and_change_userid_fields
    self.country_coordinator_lower_case = self.country_coordinator.downcase
  self.country_coordinator_lower_case = self.country_coordinator.downcase
  
  @old_userid = UseridDetail.where(:userid => self.previous_country_coordinator).first 
  @new_userid = UseridDetail.where(:userid => self.country_coordinator).first
  
  unless @old_userid.nil?
     if @old_userid.country_groups.length == 1
       @old_userid.person_role = 'transcriber'  unless (@old_userid.person_role == 'syndicate_coordinator' || @old_userid.person_role == 'country_coordinator' || @old_userid.person_role == 'system_adminstrator' || @old_userid.person_role == 'volunteer_coordinator')
     end 

     @old_userid.country_groups.delete_if {|code| code == self.country_code}
  end
    if @new_userid.country_groups.length == 0 then
     @new_userid.person_role = 'country_coordinator' if (@new_userid.person_role == 'transcriber' || @new_userid.person_role == 'syndicate_coordinator' || @new_userid.person_role == 'researcher' || @new_userid.person_role == 'conty_coordinator' )
    end 
   @new_userid.country_groups << self.country_code
   @old_userid.save!  unless @old_userid.nil?
   @new_userid.save!
    p 'after'
  
  
  
  p @new_userid.person_role
  p @new_userid.country_groups
 end

end
