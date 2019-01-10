require 'C:/openstudio-2.6.2/Ruby/openstudio'

def loadOSM(pathStr)
  translator = OpenStudio::OSVersion::VersionTranslator.new
  path = OpenStudio::Path.new(pathStr)
  model = translator.loadModel(path)
  if model.empty?
    raise "Input #{pathStr} is not valid, please check."
  else
    model = model.get
  end
  return model
end

def get_os_schedule_from_csv(file_name, model, col, skip_row)
  file_name = File.realpath(file_name)
  external_file = OpenStudio::Model::ExternalFile::getExternalFile(model, file_name)
  external_file = external_file.get
  schedule_file = OpenStudio::Model::ScheduleFile.new(external_file, col, skip_row)
  return schedule_file
end


def set_schedule_for_people(model, space_name, csv_file, people_activity_sch)
    # Test create new people and people definition instances
    new_people_def = OpenStudio::Model::PeopleDefinition.new(model)
    new_people = OpenStudio::Model::People.new(new_people_def)
    new_people_def.setName(space_name + ' people definition')

    # Set OS:People:Definition attributes
    new_people_def.setName(space_name + ' people definition')
    # !! Need to set the number of people calculation method

    # Set OS:People attributes 
    new_people.setName(space_name + ' people')
    new_people.setActivityLevelSchedule(people_activity_sch)

    people_sch = get_os_schedule_from_csv(csv_file, model, col = 3, skip_row = 7)

    new_people.setNumberofPeopleSchedule(people_sch)
    new_people.setSpace(model.getSpaces[0])

    return model

end

model = loadOSM('small_office.osm')

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Approach 1 -- create people and people definition pairs
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Create the ScheduleTypeLimits instance
test_ScheduleTypeLimits = OpenStudio::Model::ScheduleTypeLimits.new(model)
test_ScheduleTypeLimits.setFieldComment(1, 'Name')
test_ScheduleTypeLimits.setName('obFMU Any Number')

# Create the OS:Schedule:Compact instance from obFMU activity schedule
test_ActivitySchedule = OpenStudio::Model::ScheduleCompact.new(model)
test_ActivitySchedule.setName('obFMU Activity Schedule')
test_ActivitySchedule.setToConstantValue(110.7)

# Read schedule from csv
file_name = File.join(File.dirname(__FILE__), 'OccSch_out_IDF.csv')
file_name = File.realpath(file_name)



################################################################################
# Try to execute the function
################################################################################
space_name = 'Space 1'
model = set_schedule_for_people(model, space_name, file_name, test_ActivitySchedule)
space_name = 'Space 2'
model = set_schedule_for_people(model, space_name, file_name, test_ActivitySchedule)

# puts model