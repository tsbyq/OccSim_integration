require 'C:/openstudio-2.6.2/Ruby/openstudio'
require 'C:/Users/Han/Documents/GitHub/OpenStudio_related/OccSim_integration/development/OccSim_test/OccSim_integration/resources/UserLibrary.rb'


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

def obXML_builder(osModel, userLib, outPath, all_args)
  # Get general information ----------------------------------------------------

  # Get which space types are assigned to be default occupanct assumptions
  flag_space_type_occ_default = all_args[0] # Hash
  # Get specific occupancy assumptions for each space
  flag_space_occ_choice = all_args[1] # Has

  # puts flag_space_type_occ_default
  # puts flag_space_occ_choice

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


  v_space_types = osModel.getSpaceTypes
  v_meetingSpaces = Array.new()
  v_officeSpaces = Array.new()
  v_officeAreas = Array.new()
  v_nOccOffice = Array.new()
  v_allOccID = Array.new()
  v_occBhvrID = Array.new()
  v_occBhvrID = ["Regular_staff_0", "Manager_0", "Administrator_0"]
  v_holidays = Array.new()
  v_holidays = [userLib.usHolidayNewYearsDay,
    userLib.usHolidayMartinLutherKingJrDay,
    userLib.usHolidayGeorgeWashingtonsBirthday,
    userLib.usHolidayMemorialDay,
    userLib.usHolidayIndependenceDay,
    userLib.usHolidayLaborDay,
    userLib.usHolidayColumbusDay,
    userLib.usHolidayVeteransDay,
    userLib.usHolidayThanksgivingDay,
    userLib.usHolidayChristmasDay,
    userLib.customHolidayCustomHoliday_1,
    userLib.customHolidayCustomHoliday_2,
    userLib.customHolidayCustomHoliday_3,
    userLib.customHolidayCustomHoliday_4,
    userLib.customHolidayCustomHoliday_5]

  # Consider the space to be an office space if the space type is in the list
  v_office_space_types = ['WholeBuilding - Sm Office',
                          'WholeBuilding - Md Office',
                          'WholeBuilding - Lg Office',
                          'Office',
                          'ClosedOffice',
                          'OpenOffice']

  # Consider the space to be a conference space is the type is in the list
  v_conference_space_types = ['Conference']

  # Loop through all space types
  v_space_types.each do |space_type|
    # puts space_type.standardsSpaceType.to_s

    if v_office_space_types.include? space_type.standardsSpaceType.to_s
      # Do something when the space type is office
      v_officeSpaces = space_type.spaces
      v_officeSpaces.each do |officeSpace|
        # puts officeSpace
        v_officeAreas << officeSpace.floorArea
        v_nOccOffice << officeSpace.floorArea * userLib.Office_t1_OccupancyDensity
      end

    elsif v_conference_space_types.include? space_type.standardsSpaceType.to_s
      # Do something when the space type is conference room
      v_meetingSpaces = space_type.spaces
    end
  end

  # Number of space and number of people
  n_space = v_officeSpaces.length
  n_occ = 0
  v_officeSpaces.each do |officeSpace|
    n_occ += (officeSpace.floorArea / userLib.Office_t1_OccupancyDensity).floor
  end

  # Occupancy type probability hash
  # Need to apply space rules based on user selection!!!
  pDct = {
    "Regular staff" => userLib.office_t1_OccupantPercentageRegularStaff,
    "Manager" => userLib.office_t1_OccupantPercentageManager,
    "Administrator" => userLib.office_t1_OccupantPercentageAdminitrator
  }

  puts "There are #{n_space} spaces in the building"
  puts "There are #{n_occ} occupants in the building"
end

def main
  obFMU_path = 'C:/Users/Han/Documents/GitHub/OpenStudio_related/OccSim_integration/development/OccSim_test/OccSim_integration/resources/'
  output_path = obFMU_path + 'OccSimulator_out'
  model = loadOSM('C:/Users/Han/Documents/GitHub/OpenStudio_related/OccSim_integration/development/OccSim_test/OSM_2.6.2/small_office.osm')
  userLib = UserLibrary.new(obFMU_path + "library.csv")
  xml_path = './'
  all_args = {
    "Perimeter_ZN_1"=>"Office Type 1", 
    "Perimeter_ZN_2"=>"Office Type 1", 
    "Perimeter_ZN_3"=>"Office Core", 
    "Perimeter_ZN_4"=>"Office Type 3", 
    "Core_ZN"=>"Office Type 1", 
    "Attic"=>"Other"
  } 

  obXML_builder(model, userLib, xml_path, all_args)
end


main()