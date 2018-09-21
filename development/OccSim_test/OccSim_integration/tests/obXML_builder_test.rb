require 'C:/openstudio-2.6.2/Ruby/openstudio'
require 'C:/Users/Han/Documents/GitHub/OpenStudio_related/OccSim_integration/development/OccSim_test/OccSim_integration/resources/UserLibrary.rb'
require 'time'
require 'date'

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

def assignOccType(probabilityDct)
  # Build an array based on probability
  v_sample = Array.new()
  probabilityDct.each do |key, p|
    (v_sample << Array.new(probabilityDct[key] * 100, key)).flatten!
  end
  # Sample from the array
  occType = v_sample.sample
  return occType
end

def isValidDate(dateStr)
  begin
    return (Date.parse(dateStr).class.to_s == "Date")
  rescue
    return false
  end
end


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

def obXML_builder(osModel, userLib, outPath, all_args)
  # Get general information ----------------------------------------------------

  # Get which space types are assigned to be default occupanct assumptions
  flag_space_type_occ_default = all_args[0] # Hash
  # Get specific occupancy assumptions for each space
  flag_space_occ_choice = all_args

  # puts flag_space_type_occ_default
  # puts flag_space_occ_choice
  

  space_rules = space_rule_hash_wrapper(userLib)

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

  puts '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
  puts 'User selected space types:' 
  puts flag_space_occ_choice
  puts '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'

  # Loop through all space types
  v_space_types.each do |space_type|
    # puts space_type.standardsSpaceType.to_s

    if v_office_space_types.include? space_type.standardsSpaceType.to_s
      # Do something when the space type is office
      v_officeSpaces = space_type.spaces
      v_officeSpaces.each do |officeSpace|

        # puts officeSpace.name.to_s
        # puts 'Occupancy density of the current space is: ' + space_rules[space_type_selected]['OccupancyDensity'].to_s

        space_type_selected = flag_space_occ_choice[officeSpace.name.to_s]
        v_officeAreas << officeSpace.floorArea
        v_nOccOffice << officeSpace.floorArea * space_rules[space_type_selected]['OccupancyDensity']
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
    space_type_selected = flag_space_occ_choice[officeSpace.name.to_s]
    n_occ += (officeSpace.floorArea / space_rules[space_type_selected]['OccupancyDensity']).floor
  end

  # Generate the obXML file
  f = File.new(outPath + "obXML.xml",  "w")

  f.puts('<?xml version="1.0"?>')
  f.puts('<OccupantBehavior xsi:noNamespaceSchemaLocation="obXML_v1.3.2.xsd" ID="OS001" Version="1.3.2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">')
  # Buildings
  f.puts('<Buildings>')
  ## Building
  f.puts('<Building ID="Building_1">')
  ### Description
  f.puts("<Description>A office building which contains #{n_space} spaces and #{n_occ} occupants</Description>")
  ### --Description
  ### Type
  f.puts("<Type>Office</Type>")
  ### --Type
  ### Spaces
  f.puts("<Spaces ID='All_Spaces'>")
  #### Space
  f.puts("<Space ID='S0_Outdoor'>")
  ##### Space Type
  f.puts("<Type>Outdoor</Type>")
  f.puts("</Space>")

  # Add spaces to the building
  all_index = 0
  
  # ~ Meeting room spaces
  v_meetingSpaces.each_with_index do |meetingSpace, index|
    meetingSpaceName = meetingSpace.nameString
    space_type_selected = flag_space_occ_choice[meetingSpaceName]
    min_meeting_per_day = space_rules[space_type_selected]['MinimumNumberOfMeetingPerDay']
    max_meeting_per_day = space_rules[space_type_selected]['MaximumNumberOfMeetingPerDay']
    min_occupant_per_meeting = space_rules[space_type_selected]['MinimumNumberOfPeoplePerMeeting']
    max_occupant_per_meeting = space_rules[space_type_selected]['MaximumNumberOfPeoplePerMeeting']
    probabilityOf_30_minMeetings = space_rules[space_type_selected]['ProbabilityOf_30_minMeetings']
    probabilityOf_60_minMeetings = space_rules[space_type_selected]['ProbabilityOf_60_minMeetings']
    probabilityOf_90_minMeetings = space_rules[space_type_selected]['ProbabilityOf_90_minMeetings']
    probabilityOf_120_minMeetings = space_rules[space_type_selected]['ProbabilityOf_120_minMeetings']
    # Assign the information based on user library for now !!!!!!!!
    spaceIDString = "S#{index + 1 + all_index}_#{meetingSpaceName}"
    f.puts("<Space ID='" + spaceIDString + "'>")
    f.puts("<Type>MeetingRoom</Type>")
    f.puts("<MeetingEvent>")
    f.puts("<SeasonType>All</SeasonType>")
    f.puts("<MinNumOccupantsPerMeeting>#{min_occupant_per_meeting}</MinNumOccupantsPerMeeting>")
    f.puts("<MaxNumOccupantsPerMeeting>#{max_occupant_per_meeting}</MaxNumOccupantsPerMeeting>")
    f.puts("<MinNumberOfMeetingsPerDay>#{min_meeting_per_day}</MinNumberOfMeetingsPerDay>")
    f.puts("<MaxNumberOfMeetingsPerDay>#{max_meeting_per_day}</MaxNumberOfMeetingsPerDay>")

    f.puts("<MeetingDurationProbability>")
    f.puts("<MeetingDuration>PT30M</MeetingDuration>")
    f.puts("<Probability>#{probabilityOf_30_minMeetings}</Probability>")
    f.puts("</MeetingDurationProbability>")

    f.puts("<MeetingDurationProbability>")
    f.puts("<MeetingDuration>PT60M</MeetingDuration>")
    f.puts("<Probability>#{probabilityOf_60_minMeetings}</Probability>")
    f.puts("</MeetingDurationProbability>")

    f.puts("<MeetingDurationProbability>")
    f.puts("<MeetingDuration>PT90M</MeetingDuration>")
    f.puts("<Probability>#{probabilityOf_90_minMeetings}</Probability>")
    f.puts("</MeetingDurationProbability>")

    f.puts("<MeetingDurationProbability>")
    f.puts("<MeetingDuration>PT120M</MeetingDuration>")
    f.puts("<Probability>#{probabilityOf_120_minMeetings}</Probability>")
    f.puts("</MeetingDurationProbability>")

    f.puts("</MeetingEvent>")
    f.puts("</Space>")
  end

  all_index = all_index + v_meetingSpaces.length

  # ~ Office spaces
  occID_spaceName_Dct = Hash.new
  v_officeSpaces.each_with_index do |officeSpace, index|
    # Get space basic information
    officeSpaceName = officeSpace.nameString
    space_type_selected = flag_space_occ_choice[officeSpaceName]
    nOcc = (officeSpace.floorArea / space_rules[space_type_selected]['OccupancyDensity']).floor
    spaceIDString = "S#{index + 1 + all_index}_#{officeSpaceName}" + '_test'

    f.puts("<Space ID='" +  spaceIDString + "'>")
    f.puts("<Type>OfficeShared</Type>")
    # Add occupants to each space
    for i in 0..(nOcc - 1)
      occIDString = "#{spaceIDString}_O#{i + 1}"
      f.puts("<OccupantID>" + occIDString + "</OccupantID>")
      v_allOccID << occIDString
      occID_spaceName_Dct[occIDString] = officeSpaceName
    end
    f.puts("</Space>")
  end

  all_index = all_index + v_officeSpaces.length

  #### --Space
  f.puts("</Spaces>")
  ### --Spaces

  f.puts('</Building>')
  ## --Building
  f.puts('</Buildings>')
  # --Buildings

  # Occupants
  f.puts('<Occupants>')
  ## Occupant
  v_allOccID.each_with_index do |occID, index|
    f.puts("<Occupant ID='" + occID + "'>")    # puts '---->'
    space_type_selected = flag_space_occ_choice[occID_spaceName_Dct[occID]]
    f.puts("<LifeStyle>Norm</LifeStyle>")
    # Randomly assign occ type by probability
    pDct = {
      "Manager" => space_rules[space_type_selected]['OccupantPercentageManager'],
      "Administrator" => space_rules[space_type_selected]['OccupantPercentageAdminitrator'],
      "Regular staff" => space_rules[space_type_selected]['OccupantPercentageRegularStaff']
    }
    occType = assignOccType(pDct)

    f.puts("<JobType>" + occType + " </JobType>")
    # Assign movement behavior based on occ type drawed previously
    case occType
    when "Regular staff"
      occMvmntBhvrID = "Regular_staff_0"
    when "Manager"
      occMvmntBhvrID = "Manager_0"
    when "Administrator"
      occMvmntBhvrID = "Administrator_0"
    end
    f.puts("<MovementBehaviorID>" + occMvmntBhvrID + " </MovementBehaviorID>")

    f.puts("</Occupant>")
  end
  ## --Occupant
  f.puts('</Occupants>')
  # --Occupants

  # Behaviors
  f.puts('<Behaviors>')

  v_occBhvrID.each do |occBhvrID|
    ## Movement Behavior
    f.puts("<MovementBehavior ID='" + occBhvrID + "'>")
    case occBhvrID
    when "Regular_staff_0"
      # Regular Staff behaviors
      f.puts('<SeasonType>All</SeasonType>')
      f.puts('<DayofWeek>Weekdays</DayofWeek>')
      ### Random movement behavior
      f.puts('<RandomMovementEvent>')
      #### Space occupancy -- 1.OwnOffice
      f.puts('<SpaceOccupancy>')
      f.puts('<SpaceCategory>OwnOffice</SpaceCategory>')
      f.puts("<PercentTimePresence>#{userLib.regularStaffPercentOfTimeInSpaceOwnOffice}.0</PercentTimePresence>")
      f.puts("<Duration>PT#{userLib.regularStaffAverageStayTimeOwnOffice}M</Duration>")
      f.puts('</SpaceOccupancy>')
      #### --Space occupancy -- 1.OwnOffice
      #### Space occupancy -- 2.OtherOffice
      f.puts('<SpaceOccupancy>')
      f.puts('<SpaceCategory>OtherOffice</SpaceCategory>')
      f.puts("<PercentTimePresence>#{userLib.regularStaffPercentOfTimeInSpaceOtherOffices}.0</PercentTimePresence>")
      f.puts("<Duration>PT#{userLib.regularStaffAverageStayTimeOtherOffices}M</Duration>")
      f.puts('</SpaceOccupancy>')
      #### --Space occupancy -- 2.OtherOffice
      #### Space occupancy -- 3.MeetingRoom
      f.puts('<SpaceOccupancy>')
      f.puts('<SpaceCategory>MeetingRoom</SpaceCategory>')
      f.puts("<PercentTimePresence>#{userLib.regularStaffPercentOfTimeInSpaceMeetingRooms}.0</PercentTimePresence>")
      f.puts("<Duration>PT#{userLib.regularStaffAverageStayTimeMeetingRooms}M</Duration>")
      f.puts('</SpaceOccupancy>')
      #### --Space occupancy -- 3.MeetingRoom
      #### Space occupancy -- 4.AuxRoom
      f.puts('<SpaceOccupancy>')
      f.puts('<SpaceCategory>AuxRoom</SpaceCategory>')
      f.puts("<PercentTimePresence>#{userLib.regularStaffPercentOfTimeInSpaceAuxiliaryRooms}.0</PercentTimePresence>")
      f.puts("<Duration>PT#{userLib.regularStaffAverageStayTimeAuxiliaryRooms}M</Duration>")
      f.puts('</SpaceOccupancy>')
      #### --Space occupancy -- 4.AuxRoom
      #### Space occupancy -- 5.Outdoor
      f.puts('<SpaceOccupancy>')
      f.puts('<SpaceCategory>Outdoor</SpaceCategory>')
      f.puts("<PercentTimePresence>#{userLib.regularStaffPercentOfTimeInSpaceOutdoor}.0</PercentTimePresence>")
      f.puts("<Duration>PT#{userLib.regularStaffAverageStayTimeOutdoor}M</Duration>")
      f.puts('</SpaceOccupancy>')
      #### --Space occupancy -- 5.Ourdoor
      f.puts('</RandomMovementEvent>')
      ### --Random movement behavior

      ### Status transition event --1.Arrival
      f.puts('<StatusTransitionEvent>')
      f.puts('<EventType>Arrival</EventType>')
      #### Event occur model
      f.puts('<EventOccurModel>')
      f.puts('<NormalProbabilityModel>')
      timeStr = userLib.regularStaffTypicalArrivalTime
      timeVar = userLib.regularStaffArrivalTimeVariation
      f.puts('<EarlyOccurTime>' + (Time.strptime(timeStr, "%H:%M") - timeVar * 60).strftime("%H:%M:%S") + '</EarlyOccurTime>')
      f.puts("<TypicalOccurTime>#{timeStr}:00</TypicalOccurTime>")
      f.puts('</NormalProbabilityModel>')
      f.puts('</EventOccurModel>')
      #### --Event occur model
      f.puts('</StatusTransitionEvent>')
      ### --Status transition event --1.Arrival

      ### Status transition event --2.Departure
      f.puts('<StatusTransitionEvent>')
      f.puts('<EventType>Departure</EventType>')
      #### Event occur model
      f.puts('<EventOccurModel>')
      f.puts('<NormalProbabilityModel>')
      timeStr = userLib.regularStaffTypicalDepartureTime
      timeVar = userLib.regularStaffDepartureTimeVariation
      f.puts('<EarlyOccurTime>' + (Time.strptime(timeStr, "%H:%M") - timeVar * 60).strftime("%H:%M:%S") + '</EarlyOccurTime>')
      f.puts("<TypicalOccurTime>#{timeStr}:00</TypicalOccurTime>")
      f.puts('</NormalProbabilityModel>')
      f.puts('</EventOccurModel>')
      #### --Event occur model
      f.puts('</StatusTransitionEvent>')
      ### --Status transition event --2.Departure

      ### Status transition event --3.Short term leaving
      f.puts('<StatusTransitionEvent>')
      f.puts('<EventType>ShortTermLeaving</EventType>')
      #### Event occur model
      f.puts('<EventOccurModel>')
      f.puts('<NormalProbabilityModel>')
      timeStr = userLib.regularStaffTypicalShortTermLeaving
      timeVar = userLib.regularStaffShortTermLeavingVariation
      f.puts('<EarlyOccurTime>' + (Time.strptime(timeStr, "%H:%M") - timeVar * 60).strftime("%H:%M:%S") + '</EarlyOccurTime>')
      f.puts("<TypicalOccurTime>#{timeStr}:00</TypicalOccurTime>")
      f.puts('</NormalProbabilityModel>')
      f.puts('</EventOccurModel>')
      #### --Event occur model
      #### Event Duration
      f.puts('<EventDuration>')
      f.puts('<NormalDurationModel>')
      duration = userLib.regularStaffTypicalShortTermLeavingDuration
      durationVar = userLib.regularStaffShortTermLeavingDurationVariation
      f.puts("<TypicalDuration>PT#{duration}M</TypicalDuration>")
      f.puts("<MinimumDuration>PT#{duration - durationVar}M</MinimumDuration>")
      f.puts('</NormalDurationModel>')
      f.puts('</EventDuration>')
      #### --Event Duration
      f.puts('</StatusTransitionEvent>')
      ### --Status transition event --3.Short term leaving

    when "Manager_0"
      # Manager behaviors
      f.puts('<SeasonType>All</SeasonType>')
      f.puts('<DayofWeek>Weekdays</DayofWeek>')
      ### Random movement behavior
      f.puts('<RandomMovementEvent>')
      #### Space occupancy -- 1.OwnOffice
      f.puts('<SpaceOccupancy>')
      f.puts('<SpaceCategory>OwnOffice</SpaceCategory>')
      f.puts("<PercentTimePresence>#{userLib.managerPercentOfTimeInSpaceOwnOffice}.0</PercentTimePresence>")
      f.puts("<Duration>PT#{userLib.managerAverageStayTimeOwnOffice}M</Duration>")
      f.puts('</SpaceOccupancy>')
      #### --Space occupancy -- 1.OwnOffice
      #### Space occupancy -- 2.OtherOffice
      f.puts('<SpaceOccupancy>')
      f.puts('<SpaceCategory>OtherOffice</SpaceCategory>')
      f.puts("<PercentTimePresence>#{userLib.managerPercentOfTimeInSpaceOtherOffices}.0</PercentTimePresence>")
      f.puts("<Duration>PT#{userLib.managerAverageStayTimeOtherOffices}M</Duration>")
      f.puts('</SpaceOccupancy>')
      #### --Space occupancy -- 2.OtherOffice
      #### Space occupancy -- 3.MeetingRoom
      f.puts('<SpaceOccupancy>')
      f.puts('<SpaceCategory>MeetingRoom</SpaceCategory>')
      f.puts("<PercentTimePresence>#{userLib.managerPercentOfTimeInSpaceMeetingRooms}.0</PercentTimePresence>")
      f.puts("<Duration>PT#{userLib.managerAverageStayTimeMeetingRooms}M</Duration>")
      f.puts('</SpaceOccupancy>')
      #### --Space occupancy -- 3.MeetingRoom
      #### Space occupancy -- 4.AuxRoom
      f.puts('<SpaceOccupancy>')
      f.puts('<SpaceCategory>AuxRoom</SpaceCategory>')
      f.puts("<PercentTimePresence>#{userLib.managerPercentOfTimeInSpaceAuxiliaryRooms}.0</PercentTimePresence>")
      f.puts("<Duration>PT#{userLib.managerAverageStayTimeAuxiliaryRooms}M</Duration>")
      f.puts('</SpaceOccupancy>')
      #### --Space occupancy -- 4.AuxRoom
      #### Space occupancy -- 5.Outdoor
      f.puts('<SpaceOccupancy>')
      f.puts('<SpaceCategory>Outdoor</SpaceCategory>')
      f.puts("<PercentTimePresence>#{userLib.managerPercentOfTimeInSpaceOutdoor}.0</PercentTimePresence>")
      f.puts("<Duration>PT#{userLib.managerAverageStayTimeOutdoor}M</Duration>")
      f.puts('</SpaceOccupancy>')
      #### --Space occupancy -- 5.Ourdoor
      f.puts('</RandomMovementEvent>')
      ### --Random movement behavior

      ### Status transition event --1.Arrival
      f.puts('<StatusTransitionEvent>')
      f.puts('<EventType>Arrival</EventType>')
      #### Event occur model
      f.puts('<EventOccurModel>')
      f.puts('<NormalProbabilityModel>')
      timeStr = userLib.managerTypicalArrivalTime
      timeVar = userLib.managerArrivalTimeVariation
      f.puts('<EarlyOccurTime>' + (Time.strptime(timeStr, "%H:%M") - timeVar * 60).strftime("%H:%M:%S") + '</EarlyOccurTime>')
      f.puts("<TypicalOccurTime>#{timeStr}:00</TypicalOccurTime>")
      f.puts('</NormalProbabilityModel>')
      f.puts('</EventOccurModel>')
      #### --Event occur model
      f.puts('</StatusTransitionEvent>')
      ### --Status transition event --1.Arrival

      ### Status transition event --2.Departure
      f.puts('<StatusTransitionEvent>')
      f.puts('<EventType>Departure</EventType>')
      #### Event occur model
      f.puts('<EventOccurModel>')
      f.puts('<NormalProbabilityModel>')
      timeStr = userLib.managerTypicalDepartureTime
      timeVar = userLib.managerDepartureTimeVariation
      f.puts('<EarlyOccurTime>' + (Time.strptime(timeStr, "%H:%M") - timeVar * 60).strftime("%H:%M:%S") + '</EarlyOccurTime>')
      f.puts("<TypicalOccurTime>#{timeStr}:00</TypicalOccurTime>")
      f.puts('</NormalProbabilityModel>')
      f.puts('</EventOccurModel>')
      #### --Event occur model
      f.puts('</StatusTransitionEvent>')
      ### --Status transition event --2.Departure

      ### Status transition event --3.Short term leaving
      f.puts('<StatusTransitionEvent>')
      f.puts('<EventType>ShortTermLeaving</EventType>')
      #### Event occur model
      f.puts('<EventOccurModel>')
      f.puts('<NormalProbabilityModel>')
      timeStr = userLib.managerTypicalShortTermLeaving
      timeVar = userLib.managerShortTermLeavingVariation
      f.puts('<EarlyOccurTime>' + (Time.strptime(timeStr, "%H:%M") - timeVar * 60).strftime("%H:%M:%S") + '</EarlyOccurTime>')
      f.puts("<TypicalOccurTime>#{timeStr}:00</TypicalOccurTime>")
      f.puts('</NormalProbabilityModel>')
      f.puts('</EventOccurModel>')
      #### --Event occur model
      #### Event Duration
      f.puts('<EventDuration>')
      f.puts('<NormalDurationModel>')
      duration = userLib.managerTypicalShortTermLeavingDuration
      durationVar = userLib.managerShortTermLeavingDurationVariation
      f.puts("<TypicalDuration>PT#{duration}M</TypicalDuration>")
      f.puts("<MinimumDuration>PT#{duration - durationVar}M</MinimumDuration>")
      f.puts('</NormalDurationModel>')
      f.puts('</EventDuration>')
      #### --Event Duration
      f.puts('</StatusTransitionEvent>')
      ### --Status transition event --3.Short term leaving

    when 'Administrator_0'
      # Administrator behaviors
      f.puts('<SeasonType>All</SeasonType>')
      f.puts('<DayofWeek>Weekdays</DayofWeek>')
      ### Random movement behavior
      f.puts('<RandomMovementEvent>')
      #### Space occupancy -- 1.OwnOffice
      f.puts('<SpaceOccupancy>')
      f.puts('<SpaceCategory>OwnOffice</SpaceCategory>')
      f.puts("<PercentTimePresence>#{userLib.administratorPercentOfTimeInSpaceOwnOffice}.0</PercentTimePresence>")
      f.puts("<Duration>PT#{userLib.administratorAverageStayTimeOwnOffice}M</Duration>")
      f.puts('</SpaceOccupancy>')
      #### --Space occupancy -- 1.OwnOffice
      #### Space occupancy -- 2.OtherOffice
      f.puts('<SpaceOccupancy>')
      f.puts('<SpaceCategory>OtherOffice</SpaceCategory>')
      f.puts("<PercentTimePresence>#{userLib.administratorPercentOfTimeInSpaceOtherOffices}.0</PercentTimePresence>")
      f.puts("<Duration>PT#{userLib.administratorAverageStayTimeOtherOffices}M</Duration>")
      f.puts('</SpaceOccupancy>')
      #### --Space occupancy -- 2.OtherOffice
      #### Space occupancy -- 3.MeetingRoom
      f.puts('<SpaceOccupancy>')
      f.puts('<SpaceCategory>MeetingRoom</SpaceCategory>')
      f.puts("<PercentTimePresence>#{userLib.administratorPercentOfTimeInSpaceMeetingRooms}.0</PercentTimePresence>")
      f.puts("<Duration>PT#{userLib.administratorAverageStayTimeMeetingRooms}M</Duration>")
      f.puts('</SpaceOccupancy>')
      #### --Space occupancy -- 3.MeetingRoom
      #### Space occupancy -- 4.AuxRoom
      f.puts('<SpaceOccupancy>')
      f.puts('<SpaceCategory>AuxRoom</SpaceCategory>')
      f.puts("<PercentTimePresence>#{userLib.administratorPercentOfTimeInSpaceAuxiliaryRooms}.0</PercentTimePresence>")
      f.puts("<Duration>PT#{userLib.administratorAverageStayTimeAuxiliaryRooms}M</Duration>")
      f.puts('</SpaceOccupancy>')
      #### --Space occupancy -- 4.AuxRoom
      #### Space occupancy -- 5.Outdoor
      f.puts('<SpaceOccupancy>')
      f.puts('<SpaceCategory>Outdoor</SpaceCategory>')
      f.puts("<PercentTimePresence>#{userLib.administratorPercentOfTimeInSpaceOutdoor}.0</PercentTimePresence>")
      f.puts("<Duration>PT#{userLib.administratorAverageStayTimeOutdoor}M</Duration>")
      f.puts('</SpaceOccupancy>')
      #### --Space occupancy -- 5.Ourdoor
      f.puts('</RandomMovementEvent>')
      ### --Random movement behavior

      ### Status transition event --1.Arrival
      f.puts('<StatusTransitionEvent>')
      f.puts('<EventType>Arrival</EventType>')
      #### Event occur model
      f.puts('<EventOccurModel>')
      f.puts('<NormalProbabilityModel>')
      timeStr = userLib.administratorTypicalArrivalTime
      timeVar = userLib.administratorArrivalTimeVariation
      f.puts('<EarlyOccurTime>' + (Time.strptime(timeStr, "%H:%M") - timeVar * 60).strftime("%H:%M:%S") + '</EarlyOccurTime>')
      f.puts("<TypicalOccurTime>#{timeStr}:00</TypicalOccurTime>")
      f.puts('</NormalProbabilityModel>')
      f.puts('</EventOccurModel>')
      #### --Event occur model
      f.puts('</StatusTransitionEvent>')
      ### --Status transition event --1.Arrival

      ### Status transition event --2.Departure
      f.puts('<StatusTransitionEvent>')
      f.puts('<EventType>Departure</EventType>')
      #### Event occur model
      f.puts('<EventOccurModel>')
      f.puts('<NormalProbabilityModel>')
      timeStr = userLib.administratorTypicalDepartureTime
      timeVar = userLib.administratorDepartureTimeVariation
      f.puts('<EarlyOccurTime>' + (Time.strptime(timeStr, "%H:%M") - timeVar * 60).strftime("%H:%M:%S") + '</EarlyOccurTime>')
      f.puts("<TypicalOccurTime>#{timeStr}:00</TypicalOccurTime>")
      f.puts('</NormalProbabilityModel>')
      f.puts('</EventOccurModel>')
      #### --Event occur model
      f.puts('</StatusTransitionEvent>')
      ### --Status transition event --2.Departure

      ### Status transition event --3.Short term leaving
      f.puts('<StatusTransitionEvent>')
      f.puts('<EventType>ShortTermLeaving</EventType>')
      #### Event occur model
      f.puts('<EventOccurModel>')
      f.puts('<NormalProbabilityModel>')
      timeStr = userLib.administratorTypicalShortTermLeaving
      timeVar = userLib.administratorShortTermLeavingVariation
      f.puts('<EarlyOccurTime>' + (Time.strptime(timeStr, "%H:%M") - timeVar * 60).strftime("%H:%M:%S") + '</EarlyOccurTime>')
      f.puts("<TypicalOccurTime>#{timeStr}:00</TypicalOccurTime>")
      f.puts('</NormalProbabilityModel>')
      f.puts('</EventOccurModel>')
      #### --Event occur model
      #### Event Duration
      f.puts('<EventDuration>')
      f.puts('<NormalDurationModel>')
      duration = userLib.administratorTypicalShortTermLeavingDuration
      durationVar = userLib.administratorShortTermLeavingDurationVariation
      f.puts("<TypicalDuration>PT#{duration}M</TypicalDuration>")
      f.puts("<MinimumDuration>PT#{duration - durationVar}M</MinimumDuration>")
      f.puts('</NormalDurationModel>')
      f.puts('</EventDuration>')
      #### --Event Duration
      f.puts('</StatusTransitionEvent>')
      ### --Status transition event --3.Short term leaving
    end
    f.puts("</MovementBehavior>")
    ## --Movement Behavior
  end
  f.puts('</Behaviors>')
  # --Behaviors

  # Holidays
  f.puts('<Holidays>')
  v_holidays.each do |hDate|
    if (isValidDate(hDate))
      ## Holiday
      f.puts('<Holiday>')
      f.puts('<Date>' + hDate + '</Date>')
      f.puts('</Holiday>')
      ## --Holiday
    end
  end
  f.puts('</Holidays>')
  f.puts('</OccupantBehavior>')

  f.close

  puts '------------------------------------------------------------------'
  puts 'obXMl.xml file created.'
  puts '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'

end

def main
  obFMU_path = 'C:/Users/Han/Documents/GitHub/OpenStudio_related/OccSim_integration/development/OccSim_test/OccSim_integration/resources/'
  output_path = obFMU_path + 'OccSimulator_out'
  # model = loadOSM('C:/Users/Han/Documents/GitHub/OpenStudio_related/OccSim_integration/development/OccSim_test/OSM_2.6.2/small_office.osm')
  model = loadOSM('C:/Users/Han/Documents/GitHub/OpenStudio_related/OccSim_integration/development/OccSim_test/OSM_2.6.2/small_office_w_meeting.osm')
  userLib = UserLibrary.new(obFMU_path + "library.csv")
  xml_path = './'
  all_args = {
    "Perimeter_ZN_1"=>"Office Type 1", 
    "Perimeter_ZN_2"=>"Office Top Floor", 
    "Perimeter_ZN_3"=>"Office Core", 
    "Perimeter_ZN_4"=>"Office Type 3", 
    "Core_ZN"=>"Meeting Room Type 2", 
    "Attic"=>"Other"
  } 

  obXML_builder(model, userLib, xml_path, all_args)
end


main()