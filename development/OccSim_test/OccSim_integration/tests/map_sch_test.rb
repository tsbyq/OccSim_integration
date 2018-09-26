def space_rule_hash_wrapper(userLib)
    # Create hashes to store space rules available in the library
  # Office spaces
  office_t1 = {
    'name' => userLib.Office_t1_name,
    'OccupancyDensity' => userLib.Office_t1_OccupancyDensity,
    'OccupantPercentageManager' => userLib.office_t1_OccupantPercentageManager,
    'OccupantPercentageAdminitrator' => userLib.office_t1_OccupantPercentageAdminitrator,
    'OccupantPercentageRegularStaff' => userLib.office_t1_OccupantPercentageRegularStaff
  }
  office_t2 = {
    'name' => userLib.Office_t2_name,
    'OccupancyDensity' => userLib.Office_t2_OccupancyDensity,
    'OccupantPercentageManager' => userLib.office_t2_OccupantPercentageManager,
    'OccupantPercentageAdminitrator' => userLib.office_t2_OccupantPercentageAdminitrator,
    'OccupantPercentageRegularStaff' => userLib.office_t2_OccupantPercentageRegularStaff
  }
  office_t3 = {
    'name' => userLib.Office_t3_name,
    'OccupancyDensity' => userLib.Office_t3_OccupancyDensity,
    'OccupantPercentageManager' => userLib.office_t3_OccupantPercentageManager,
    'OccupantPercentageAdminitrator' => userLib.office_t3_OccupantPercentageAdminitrator,
    'OccupantPercentageRegularStaff' => userLib.office_t3_OccupantPercentageRegularStaff
  }
  office_t4 = {
    'name' => userLib.Office_t4_name,
    'OccupancyDensity' => userLib.Office_t4_OccupancyDensity,
    'OccupantPercentageManager' => userLib.office_t4_OccupantPercentageManager,
    'OccupantPercentageAdminitrator' => userLib.office_t4_OccupantPercentageAdminitrator,
    'OccupantPercentageRegularStaff' => userLib.office_t4_OccupantPercentageRegularStaff
  }
  office_t5 = {
    'name' => userLib.Office_t5_name,
    'OccupancyDensity' => userLib.Office_t5_OccupancyDensity,
    'OccupantPercentageManager' => userLib.office_t5_OccupantPercentageManager,
    'OccupantPercentageAdminitrator' => userLib.office_t5_OccupantPercentageAdminitrator,
    'OccupantPercentageRegularStaff' => userLib.office_t5_OccupantPercentageRegularStaff
  }

  # Meeting spaces
  meeting_t1 = {
    'name' => userLib.meetingRoom_t1_name,
    'MinimumNumberOfMeetingPerDay' => userLib.meetingRoom_t1_MinimumNumberOfMeetingPerDay,
    'MaximumNumberOfMeetingPerDay' => userLib.meetingRoom_t1_MaximumNumberOfMeetingPerDay,
    'MinimumNumberOfPeoplePerMeeting' => userLib.meetingRoom_t1_MinimumNumberOfPeoplePerMeeting,
    'MaximumNumberOfPeoplePerMeeting' => userLib.meetingRoom_t1_MaximumNumberOfPeoplePerMeeting,
    'ProbabilityOf_30_minMeetings' => userLib.meetingRoom_t1_ProbabilityOf_30_minMeetings,
    'ProbabilityOf_60_minMeetings' => userLib.meetingRoom_t1_ProbabilityOf_60_minMeetings,
    'ProbabilityOf_90_minMeetings' => userLib.meetingRoom_t1_ProbabilityOf_90_minMeetings,
    'ProbabilityOf_120_minMeetings' => userLib.meetingRoom_t1_ProbabilityOf_120_minMeetings
  }
  meeting_t2 = {
    'name' => userLib.meetingRoom_t2_name,
    'MinimumNumberOfMeetingPerDay' => userLib.meetingRoom_t2_MinimumNumberOfMeetingPerDay,
    'MaximumNumberOfMeetingPerDay' => userLib.meetingRoom_t2_MaximumNumberOfMeetingPerDay,
    'MinimumNumberOfPeoplePerMeeting' => userLib.meetingRoom_t2_MinimumNumberOfPeoplePerMeeting,
    'MaximumNumberOfPeoplePerMeeting' => userLib.meetingRoom_t2_MaximumNumberOfPeoplePerMeeting,
    'ProbabilityOf_30_minMeetings' => userLib.meetingRoom_t2_ProbabilityOf_30_minMeetings,
    'ProbabilityOf_60_minMeetings' => userLib.meetingRoom_t2_ProbabilityOf_60_minMeetings,
    'ProbabilityOf_90_minMeetings' => userLib.meetingRoom_t2_ProbabilityOf_90_minMeetings,
    'ProbabilityOf_120_minMeetings' => userLib.meetingRoom_t2_ProbabilityOf_120_minMeetings
  }
  meeting_t3 = {
    'name' => userLib.meetingRoom_t3_name,
    'MinimumNumberOfMeetingPerDay' => userLib.meetingRoom_t3_MinimumNumberOfMeetingPerDay,
    'MaximumNumberOfMeetingPerDay' => userLib.meetingRoom_t3_MaximumNumberOfMeetingPerDay,
    'MinimumNumberOfPeoplePerMeeting' => userLib.meetingRoom_t3_MinimumNumberOfPeoplePerMeeting,
    'MaximumNumberOfPeoplePerMeeting' => userLib.meetingRoom_t3_MaximumNumberOfPeoplePerMeeting,
    'ProbabilityOf_30_minMeetings' => userLib.meetingRoom_t3_ProbabilityOf_30_minMeetings,
    'ProbabilityOf_60_minMeetings' => userLib.meetingRoom_t3_ProbabilityOf_60_minMeetings,
    'ProbabilityOf_90_minMeetings' => userLib.meetingRoom_t3_ProbabilityOf_90_minMeetings,
    'ProbabilityOf_120_minMeetings' => userLib.meetingRoom_t3_ProbabilityOf_120_minMeetings
  }
  meeting_t4 = {
    'name' => userLib.meetingRoom_t4_name,
    'MinimumNumberOfMeetingPerDay' => userLib.meetingRoom_t4_MinimumNumberOfMeetingPerDay,
    'MaximumNumberOfMeetingPerDay' => userLib.meetingRoom_t4_MaximumNumberOfMeetingPerDay,
    'MinimumNumberOfPeoplePerMeeting' => userLib.meetingRoom_t4_MinimumNumberOfPeoplePerMeeting,
    'MaximumNumberOfPeoplePerMeeting' => userLib.meetingRoom_t4_MaximumNumberOfPeoplePerMeeting,
    'ProbabilityOf_30_minMeetings' => userLib.meetingRoom_t4_ProbabilityOf_30_minMeetings,
    'ProbabilityOf_60_minMeetings' => userLib.meetingRoom_t4_ProbabilityOf_60_minMeetings,
    'ProbabilityOf_90_minMeetings' => userLib.meetingRoom_t4_ProbabilityOf_90_minMeetings,
    'ProbabilityOf_120_minMeetings' => userLib.meetingRoom_t4_ProbabilityOf_120_minMeetings
  }
  meeting_t5 = {
    'name' => userLib.meetingRoom_t5_name,
    'MinimumNumberOfMeetingPerDay' => userLib.meetingRoom_t5_MinimumNumberOfMeetingPerDay,
    'MaximumNumberOfMeetingPerDay' => userLib.meetingRoom_t5_MaximumNumberOfMeetingPerDay,
    'MinimumNumberOfPeoplePerMeeting' => userLib.meetingRoom_t5_MinimumNumberOfPeoplePerMeeting,
    'MaximumNumberOfPeoplePerMeeting' => userLib.meetingRoom_t5_MaximumNumberOfPeoplePerMeeting,
    'ProbabilityOf_30_minMeetings' => userLib.meetingRoom_t5_ProbabilityOf_30_minMeetings,
    'ProbabilityOf_60_minMeetings' => userLib.meetingRoom_t5_ProbabilityOf_60_minMeetings,
    'ProbabilityOf_90_minMeetings' => userLib.meetingRoom_t5_ProbabilityOf_90_minMeetings,
    'ProbabilityOf_120_minMeetings' => userLib.meetingRoom_t5_ProbabilityOf_120_minMeetings
  }

  space_rules = {
    userLib.Office_t1_name => office_t1,
    userLib.Office_t2_name => office_t2,
    userLib.Office_t3_name => office_t3,
    userLib.Office_t4_name => office_t4,
    userLib.Office_t5_name => office_t5,
    userLib.meetingRoom_t1_name => meeting_t1,
    userLib.meetingRoom_t2_name => meeting_t2,
    userLib.meetingRoom_t3_name => meeting_t3,
    userLib.meetingRoom_t4_name => meeting_t4,
    userLib.meetingRoom_t5_name => meeting_t5
  }
  return space_rules
end

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
  schedule_type_limit = OpenStudio::Model::ScheduleTypeLimits .new(model)
  schedule_file.setScheduleTypeLimits(schedule_type_limit)
  return schedule_file
end

def single_zone_test
  require 'C:/openstudio-2.6.2/Ruby/openstudio'
  require 'C:/Users/Han/Documents/GitHub/OpenStudio_related/OccSim_integration/development/OccSim_test/OccSim_integration/resources/UserLibrary.rb'

  obFMU_path = 'C:/Users/Han/Documents/GitHub/OpenStudio_related/OccSim_integration/development/OccSim_test/OccSim_integration/resources/'
  output_path = obFMU_path + 'OccSimulator_out'
  model = loadOSM('C:/Users/Han/Documents/GitHub/OpenStudio_related/OccSim_integration/development/OccSim_test/OSM_2.6.2/small_office_w_meeting.osm')
  csv_file_path = './OccSch_out.csv'
  userLib = UserLibrary.new(obFMU_path + "library.csv")

  peoples = model.getPeoples
  peopleDefs = model.getPeopleDefinitions

  # puts peoples[0]
  # puts peopleDefs[0]
  # puts peopleDefs[0].numberofPeopleCalculationMethod
  # puts peopleDefs[0].numberofPeopleCalculationMethod.class.name
  # puts peopleDefs[0].setNumberOfPeopleCalculationMethod('People/Area', 2)
  
  puts model.getSpaces[0].spaceType.methods

end

def set_schedule_for_people(model, space_name, csv_file, userLib, all_args)
  # puts '----------------------------------------------------------------------'
  # puts 'Current space scanned: ' + space_name
  space_rules = space_rule_hash_wrapper(userLib)
  occ_type_arg_vals = all_args[1]
  space_ID_map = all_args[2]
  space_type_selected = occ_type_arg_vals[space_name]

  # puts 'Corresponding user selected space type: ' + space_type_selected
  # puts '~~~~~~~~~~~~~~~~~~~~~~~~~~ Space Rules ~~~~~~~~~~~~~~~~~~~~~~~~~~'
  # Only office and meeting spaces have space rules for now
  if not space_rules[space_type_selected].nil?
    puts 'Proceed...'
    # Create people activity schedule
    people_activity_sch = OpenStudio::Model::ScheduleCompact.new(model)
    people_activity_sch.setName('obFMU Activity Schedule')
    people_activity_sch.setToConstantValue(110.7)
  
    # Set OS:People:Definition attributes
    new_people_def = OpenStudio::Model::PeopleDefinition.new(model)
    puts "Set people definition name: " + new_people_def.setName(space_name + ' people definition').to_s
  
    # Test create new people and people definition instances
    new_people = OpenStudio::Model::People.new(new_people_def)
    puts "Set people name: " + new_people.setName(space_name + ' people').to_s
    puts "Set people activity schedule: " + new_people.setActivityLevelSchedule(people_activity_sch).to_s

    # Check if the space is office or meeting room.
    if space_rules[space_type_selected]['OccupancyDensity'].nil?
      # The current space is a meeting room
      n_people = space_rules[space_type_selected]['MaximumNumberOfPeoplePerMeeting']
      puts "Set number of people calculation method: " + new_people_def.setNumberOfPeopleCalculationMethod('People', 1).to_s
      puts "Set number of people: " + new_people_def.setNumberofPeople(n_people).to_s
    else
      # The current space is a office room
      people_per_area = 1.0/space_rules[space_type_selected]['OccupancyDensity'] # reciprocal of area/person in the user defined library
      puts "Set number of people calculation method: " + new_people_def.setNumberOfPeopleCalculationMethod('People/Area', 1).to_s
      puts "Set people per floor area: " + new_people_def.setPeopleperSpaceFloorArea(people_per_area).to_s
    end
    # Map the schedule to space
    # Get the column number in the output schedule file by space name
    col_number = space_ID_map[space_name] + 2 # Skip col 1: step and col 2: time
    puts 'Column in the csv file: ' + col_number.to_s
    people_sch = get_os_schedule_from_csv(csv_file, model, col = col_number, skip_row = 7)
    puts new_people.setNumberofPeopleSchedule(people_sch)

    model.getSpaces.each do |current_space|
      if current_space.nameString == space_name
        new_people.setSpace(current_space)
      end
    end

  end
  return model
end

def set_schedule_for_people_clean(model, space_name, csv_file, userLib, all_args)
  space_rules = space_rule_hash_wrapper(userLib)
  occ_type_arg_vals = all_args[1]
  space_ID_map = all_args[2]
  space_type_selected = occ_type_arg_vals[space_name]


  # Only office and meeting spaces have space rules for now
  if not space_rules[space_type_selected].nil?

    # Create people activity schedule
    people_activity_sch = OpenStudio::Model::ScheduleCompact.new(model)
    people_activity_sch.setName('obFMU Activity Schedule')
    people_activity_sch.setToConstantValue(110.7)
  
    # Set OS:People:Definition attributes
    new_people_def = OpenStudio::Model::PeopleDefinition.new(model)
    new_people_def.setName(space_name + ' people definition')
  
    # Test create new people and people definition instances
    new_people = OpenStudio::Model::People.new(new_people_def)
    new_people.setName(space_name + ' people')
    new_people.setActivityLevelSchedule(people_activity_sch)

    puts space_name

    # Check if the space is office or meeting room.
    if space_rules[space_type_selected]['OccupancyDensity'].nil?
      # The current space is a meeting room
      n_people = space_rules[space_type_selected]['MaximumNumberOfPeoplePerMeeting']
      new_people_def.setNumberOfPeopleCalculationMethod('People', 1)
      new_people_def.setNumberofPeople(n_people)
    else
      # The current space is a office room
      people_per_area = 1.0/space_rules[space_type_selected]['OccupancyDensity'] # reciprocal of area/person in the user defined library
      new_people_def.setNumberOfPeopleCalculationMethod('People/Area', 1)
      new_people_def.setPeopleperSpaceFloorArea(people_per_area)
    end
    # Map the schedule to space
    # Get the column number in the output schedule file by space name
    col_number = space_ID_map[space_name] + 2 # Skip col 1: step and col 2: time
    people_sch = get_os_schedule_from_csv(csv_file, model, col = col_number, skip_row = 7)
    # Set minute per item (timestep = 10min) May need to change !!!
    people_sch.setMinutesperItem('10')
    new_people.setNumberofPeopleSchedule(people_sch)



    # Add schedule to the right space
    model.getSpaces.each do |current_space|
      if current_space.nameString == space_name
        new_people.setSpace(current_space)
      end
    end
  end

  return model
end


def main
  require 'C:/openstudio-2.6.2/Ruby/openstudio'
  require 'C:/Users/Han/Documents/GitHub/OpenStudio_related/OccSim_integration/development/OccSim_test/OccSim_integration/resources/UserLibrary.rb'

  obFMU_path = 'C:/Users/Han/Documents/GitHub/OpenStudio_related/OccSim_integration/development/OccSim_test/OccSim_integration/resources/'
  output_path = obFMU_path + 'OccSimulator_out'
  # model = loadOSM('C:/Users/Han/Documents/GitHub/OpenStudio_related/OccSim_integration/development/OccSim_test/OSM_2.6.2/small_office_w_meeting.osm')
  model = loadOSM('C:/Users/Han/Documents/GitHub/OpenStudio_related/OccSim_integration/development/OccSim_test/OccSim_integration/tests/Final/small_office.osm')
  csv_file_path = './OccSch_out_IDF.csv'

  userLib = UserLibrary.new(obFMU_path + "library.csv")

  occ_type_arg_vals = {
    "Perimeter_ZN_1"=>"Office Type 1", 
    "Perimeter_ZN_2"=>"Office Type 3", 
    "Perimeter_ZN_3"=>"Office Type 1", 
    "Perimeter_ZN_4"=>"Office Type 1", 
    "Core_ZN"=>"Meeting Room Type 1", 
    "Attic"=>"Other"
  }

  space_ID_map = {
    "Core_ZN"=>1,
    "Perimeter_ZN_1"=>2,
    "Perimeter_ZN_2"=>3,
    "Perimeter_ZN_3"=>4,
    "Perimeter_ZN_4"=>5
  }

  all_args = []
  all_args[0] = ['']
  all_args[1] = occ_type_arg_vals
  all_args[2] = space_ID_map

  # puts all_args
  # Remove all people object (if exist) in the old model
  model.getPeoples.each do |os_people|
    os_people.remove
  end

  model.getPeopleDefinitions.each do |os_people_def|
    os_people_def.remove
  end

  model.getSpaces.each do |space|
    # model = set_schedule_for_people(model, space.name.to_s, csv_file_path, userLib, all_args)
    model = set_schedule_for_people_clean(model, space.name.to_s, csv_file_path, userLib, all_args)
  end

  # puts model
  puts '-----------------------------------------------------------------------'

  root_path = File.dirname(__FILE__) + '/resources/'

  puts root_path



  # model.getExternalFiles.each do |external_file|

  #   puts external_file.fileName == 'OccSch_out_IDF.csv'
  #   puts external_file.filePath
  #   puts model.getExternalFiles[0].setString(2, '1') # Set the csv file with absolute path
  # end


  # # puts model.getExternalFiles[0]
  # puts '-----------------------------------------------------------------------'
  # puts model.getExternalFiles[0]
  # puts model.getExternalFiles[0].getString(-1)
  # puts model.getExternalFiles[0].getString(0)
  # puts model.getExternalFiles[0].getString(1)
  # puts model.getExternalFiles[0].getString(2)
  # puts model.getExternalFiles[0].setString(2, '1')
  # puts model.getExternalFiles[0]

  pp = 'C:/Users/Han/Documents/GitHub/OpenStudio_related/OccSim_integration/development/OccSim_test/OccSim_integration/tests/Final/SO'

  File.open(pp + '/stand_alone.osm', 'w') { |file| file.write(model) }

end



# test()

main()

# single_zone_test()