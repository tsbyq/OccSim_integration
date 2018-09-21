
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


def set_schedule_for_people(model, space_name, csv_file, userLib, all_args)

  all_args.each do |key_space_name, space_type_selected|
    if key_space_name == space_name
      puts 'User selected space type from library: ' + key_space_name + '----' + space_type_selected
    end
  end

  # Create people activity schedule
  people_activity_sch = OpenStudio::Model::ScheduleCompact.new(model)
  people_activity_sch.setName('obFMU Activity Schedule')
  people_activity_sch.setToConstantValue(110.7)
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




def main
  require 'C:/openstudio-2.6.2/Ruby/openstudio'
  require 'C:/Users/Han/Documents/GitHub/OpenStudio_related/OccSim_integration/development/OccSim_test/OccSim_integration/resources/UserLibrary.rb'

  obFMU_path = 'C:/Users/Han/Documents/GitHub/OpenStudio_related/OccSim_integration/development/OccSim_test/OccSim_integration/resources/'
  output_path = obFMU_path + 'OccSimulator_out'
  model = loadOSM('C:/Users/Han/Documents/GitHub/OpenStudio_related/OccSim_integration/development/OccSim_test/OSM_2.6.2/small_office.osm')
  csv_file_path = './OccSch_out_IDF.csv'
  userLib = UserLibrary.new(obFMU_path + "library.csv")

  all_args = {
    "Perimeter_ZN_1"=>"Office Type 1", 
    "Perimeter_ZN_2"=>"Office Type 1", 
    "Perimeter_ZN_3"=>"Office Core", 
    "Perimeter_ZN_4"=>"Office Type 3", 
    "Core_ZN"=>"Office Type 1", 
    "Attic"=>"Other"
  } 

  model.getSpaces.each do |space|
    puts 'Current space scanned: ' + space.name.to_s
    model = set_schedule_for_people(model, space.name.to_s, csv_file_path, userLib, all_args)
  end

  # puts model

  

end


# main()

st = 'S2_Perimeter_ZN_1_O3'
puts st
space_name = st.split('_')[1] + '_' + st.split('_')[2] + '_' + st.split('_')[3]
puts space_name