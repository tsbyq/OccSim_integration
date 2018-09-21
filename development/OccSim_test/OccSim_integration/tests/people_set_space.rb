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


def set_schedule_for_people(schedule_file)

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
# test_ActivitySchedule.setScheduleTypeLimits(test_ScheduleTypeLimits)

# Test create new people and people definition instances
test_people_definition = OpenStudio::Model::PeopleDefinition.new(model)
test_people = OpenStudio::Model::People.new(test_people_definition)


# Set OS:People:Definition attributes 
test_people_definition.setName('Zone x people definition')

# Set OS:People attributes 
test_people.setName('Zone x people')
test_people.setActivityLevelSchedule(test_ActivitySchedule)


# Read schedule from csv
file_name = File.join(File.dirname(__FILE__), 'OccSch_out_IDF.csv')
file_name = File.realpath(file_name)
external_file = OpenStudio::Model::ExternalFile::getExternalFile(model, file_name)
external_file = external_file.get


schedule_file = get_os_schedule_from_csv(file_name, model, 3, 1)



puts test_people.setNumberofPeopleSchedule(schedule_file)
puts test_people.setSpace(model.getSpaces[0])


puts model

# puts test_people
# puts test_people_definition
# puts schedule_file
# puts schedule_file.externalFile
# puts test_ActivitySchedule

# # Read schedule:file from model
# workspace_translator = OpenStudio::EnergyPlus::ReverseTranslator.new()
# workspace_obFMU_idf = OpenStudio::Workspace::load('C:/Users/Han/Documents/GitHub/OpenStudio_related/OccSim_integration/development/OccSim_test/OSM_2.6.2/OccSch_out_IDF.idf').get

# workspace_obFMU_idf.objects.each do |idf_object|
#     if(['Schedule:Compact', 'ScheduleTypeLimits', 'Zone', 'People'].include? idf_object.iddObject.name)
#         workspace_obFMU_idf.removeObject(idf_object.handle)
#     end
# end

# obFMU_osm = workspace_translator.translateWorkspace(workspace_obFMU_idf)

# # puts obFMU_osm.objects
# # puts obFMU_osm.objects[1].to_ScheduleFile.get
# puts obFMU_osm.objects[1].to_ScheduleFile.get.externalFile

# puts test_people.setNumberofPeopleSchedule(obFMU_osm.objects[1].to_ScheduleFile.get)