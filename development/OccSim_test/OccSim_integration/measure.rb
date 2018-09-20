require 'openstudio'
require 'time'
require 'date'


# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

# start the measure
class OccSim_integration < OpenStudio::Measure::ModelMeasure

  # human readable name
  def name
    return "OccSim_integration"
  end

  # human readable description
  def description
    return "Replace this text with an explanation of what the measure does in terms that can be understood by a general building professional audience (building owners, architects, engineers, contractors, etc.).  This description will be used to create reports aimed at convincing the owner and/or design team to implement the measure in the actual building design.  For this reason, the description may include details about how the measure would be implemented, along with explanations of qualitative benefits associated with the measure.  It is good practice to include citations in the measure if the description is taken from a known source or if specific benefits are listed."
  end

  # human readable description of modeling approach
  def modeler_description
    return "Replace this text with an explanation for the energy modeler specifically. It should explain how the measure is modeled, including any requirements about how the baseline model must be set up, major assumptions, citations of references to applicable modeling resources, etc.  The energy modeler should be able to read this description and understand what changes the measure is making to the model and why these changes are being made.  Because the Modeler Description is written for an expert audience, using common abbreviations for brevity is good practice."
  end

  # define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Measure::OSArgumentVector.new

    ############################################################################
    # Prepare options for the apply measure now GUI
    ############################################################################
    # Let the user choose whether they want to use default occupancy asumptions.
    # Make an argument for each Space_type in the model
    model.getSpaceTypes.each do |space_type|
      next if not space_type.spaces.size > 0 # Skip the space type which is not assigned to any space
      space_type_name = space_type.name.get.to_s # lowercase, no spaces or special characters
      # the name of the space to add to the model
      st_arg = OpenStudio::Measure::OSArgument.makeBoolArgument("#{space_type_name}_val", true)
      st_arg.setDisplayName("Use default assumptions for #{space_type.name}")
      st_arg.setDefaultValue(true)
      args << st_arg
    end

    # Read user pre-defined library
    root_path = File.dirname(__FILE__) + '/resources/'
    # Load reauired class and gem files
    load root_path + 'UserLibrary.rb'
    userLib = UserLibrary.new(root_path + "library.csv")

    # the name of the space to add to the model

    # Space type choices
    space_type_chs = OpenStudio::StringVector.new
    space_type_chs << userLib.Office_t1_name
    space_type_chs << userLib.Office_t2_name
    space_type_chs << userLib.Office_t3_name
    space_type_chs << userLib.Office_t4_name
    space_type_chs << userLib.Office_t5_name
    space_type_chs << userLib.meetingRoom_t1_name
    space_type_chs << userLib.meetingRoom_t2_name
    space_type_chs << userLib.meetingRoom_t3_name
    space_type_chs << userLib.meetingRoom_t4_name
    space_type_chs << userLib.meetingRoom_t5_name
    space_type_chs << "Auxiliary"
    space_type_chs << "Lobby"
    space_type_chs << "Corridor"
    space_type_chs << "Other"

    # v_spaces = Array.new()
    # v_spaces = model.getSpaces
    v_space_types = model.getSpaceTypes

    # Standard space types for office rooms
    v_office_space_types = ['WholeBuilding - Sm Office',
                            'WholeBuilding - Md Office',
                            'WholeBuilding - Lg Office',
                            'Office',
                            'ClosedOffice',
                            'OpenOffice']
    # Standard space types for meeting rooms
    v_conference_space_types = ['Conference']
    # Standard space types for auxiliary rooms
    v_auxiliary_space_types = ['OfficeLarge Data Center',
                               'OfficeLarge Main Data Center']

    i = 1
    # Loop through all space types, group spaces by their types
    v_space_types.each do |space_type|
      # Loop through all spaces of current space type
      v_current_spaces = space_type.spaces
      next if not v_current_spaces.size > 0
      v_current_spaces.each do |current_space|
        arg_temp = OpenStudio::Measure::OSArgument::makeChoiceArgument("Space_#{i}_" + current_space.nameString, space_type_chs, true)
        arg_temp.setDisplayName("Space #{i}: " + current_space.nameString)
        # Conditionally set the default choice for the space
        if(v_office_space_types.include? space_type.standardsSpaceType.to_s)
          arg_temp.setDefaultValue('Office Type 1')
        elsif(v_conference_space_types.include? space_type.standardsSpaceType.to_s)
          arg_temp.setDefaultValue('Meeting Room Type 1')
        elsif(v_auxiliary_space_types.include? space_type.standardsSpaceType.to_s)
          arg_temp.setDefaultValue('Auxiliary')
        elsif(space_type.standardsSpaceType.to_s == '')
          # If the space type is not in standard space types
          arg_temp.setDefaultValue('Other')
        end
        args << arg_temp
        i += 1
      end
    end
    return args
  end

  # Utility functions for the OccSim integration
  ################################## Functions #################################
  # Utility function, read a model from a osm file and translate it to the
  # current OS version
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

  #
  # [assignOccType description]
  # @param probabilityDct [Hash] A hash table of occupancy type and its probability
  #
  # @return [String] Occupancy type in String
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

  #
  # Utility function, check if a string can be parsed to a date
  # @param dateStr [String] original date string
  #
  # @return [Boolean] if the string can be parsed to date
  def isValidDate(dateStr)
    begin
      return (Date.parse(dateStr).class.to_s == "Date")
    rescue
      return false
    end
  end

  #
  # Primary function, build a obXML from OpenStudio model and pre-defined library
  # @param osModel [OpenStudio::Model::Model]
  # @param userLib [UserLibrary]
  #
  # @return [type] [description]
  def obXML_builder(osModel, userLib, outPath, all_args)
    # Get general information ----------------------------------------------------

    # Get which space types are assigned to be default occupanct assumptions
    flag_space_type_occ_default = all_args[0] # Hash
    # Get specific occupancy assumptions for each space
    flag_space_occ_choice = all_args[1] # Has

    # puts flag_space_type_occ_default
    # puts flag_space_occ_choice

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

      puts space_type
      if v_office_space_types.include? space_type.standardsSpaceType.to_s
        # Do something when the space type is office
        v_officeSpaces = space_type.spaces
        v_officeSpaces.each do |officeSpace|
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
    pDct = {
      "Regular staff" => userLib.office_t1_OccupantPercentageRegularStaff,
      "Manager" => userLib.office_t1_OccupantPercentageManager,
      "Administrator" => userLib.office_t1_OccupantPercentageAdminitrator
    }

    puts "There are #{n_space} spaces in the building"
    puts "There are #{n_occ} occupants in the building"

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
    min_occupant_per_meeting = userLib.meetingRoom_t1_MinimumNumberOfPeoplePerMeeting
    max_occupant_per_meeting = userLib.meetingRoom_t1_MaximumNumberOfPeoplePerMeeting
    min_meeting_per_day = userLib.meetingRoom_t1_MinimumNumberOfMeetingPerDay
    max_meeting_per_day = userLib.meetingRoom_t1_MaximumNumberOfMeetingPerDay
    probabilityOf_30_minMeetings = userLib.meetingRoom_t1_ProbabilityOf_30_minMeetings
    probabilityOf_60_minMeetings = userLib.meetingRoom_t1_ProbabilityOf_60_minMeetings
    probabilityOf_90_minMeetings = userLib.meetingRoom_t1_ProbabilityOf_90_minMeetings
    probabilityOf_120_minMeetings = userLib.meetingRoom_t1_ProbabilityOf_120_minMeetings
    # ~ Meeting room spaces
    v_meetingSpaces.each_with_index do |meetingSpace, index|
      meetingSpaceName = meetingSpace.nameString
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
    v_officeSpaces.each_with_index do |officeSpace, index|
      # Get space basic information
      officeSpaceName = officeSpace.nameString
      nOcc = (officeSpace.floorArea / userLib.Office_t1_OccupancyDensity).floor
      spaceIDString = "S#{index + 1 + all_index}_#{officeSpaceName}"

      f.puts("<Space ID='" +  spaceIDString + "'>")
      f.puts("<Type>OfficeShared</Type>")
      # Add occupants to each space
      for i in 0..(nOcc - 1)
        occIDString = "#{spaceIDString}_O#{i + 1}"
        f.puts("<OccupantID>" + occIDString + "</OccupantID>")
        v_allOccID << occIDString
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
      f.puts("<Occupant ID='" + occID + "'>")
      f.puts("<LifeStyle>Norm</LifeStyle>")
      # Randomly assign occ type by probability
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

    puts 'obXMl.xml file created.'
  end

  # This function build a CoSimXMl.xml file
  # All the fields are default
  def coSimXML_builder(outPath)
    f = File.new(outPath + "obCoSim.xml",  "w")
    # CoSimulationParameters
    f.puts('<CoSimulationParameters>')
    ## SpaceNameMapping
    f.puts('<SpaceNameMapping>')
    f.puts('<obXML_SpaceID>ID_Holder</obXML_SpaceID>')
    f.puts('<FMU_InstanceName>place_holder</FMU_InstanceName>')
    f.puts('</SpaceNameMapping>')
    ## --SpaceNameMapping
    ## Simulation setting
    f.puts('<SimulationSettings>')
    f.puts('<IsLeapYear>Yes</IsLeapYear>')
    f.puts('<DayofWeekForStartDay>Monday</DayofWeekForStartDay>')
    f.puts('<IsDebugMode>No</IsDebugMode>')
    f.puts('<DoMovementCalculation>Yes</DoMovementCalculation>')
    f.puts('<StartMonth>1</StartMonth>')
    f.puts('<StartDay>1</StartDay>')
    f.puts('<EndMonth>12</EndMonth>')
    f.puts('<EndDay>31</EndDay>')
    f.puts('<NumberofTimestepsPerHour>6</NumberofTimestepsPerHour>')
    f.puts('</SimulationSettings>')
    ## --Simulation setting
    f.puts('</CoSimulationParameters>')
    # --CoSimulationParameters
    f.close

    puts 'coSimXML.xml file created.'
  end

  ##############################################################################
  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # use the built-in error checking
    if !runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    # get current file directory
    obFMU_path = File.dirname(__FILE__) + '/resources/'

    # check the obFMU_path for reasonableness
    if obFMU_path.empty?
      runner.registerError("Empty path was entered.")
      return false
    end

    # Load reauired class
    load obFMU_path + 'UserLibrary.rb'

    # report initial condition of model
    runner.registerInitialCondition("Start.")

    ### Get user input for whether to use default assumptions by space types
    v_space_types = model.getSpaceTypes
    space_type_arg_vals = {}
    v_space_types.each do |space_type|
      space_type_name = space_type.name.get.to_s
      st_val = runner.getBoolArgumentValue("#{space_type_name}_val", user_arguments)
      space_type_arg_vals[space_type_name] = st_val
    end

    ### Get user selected occupancy assumptions for each space
    i = 1
    occ_type_arg_vals = {}
    # Loop through all space types, group spaces by their types
    v_space_types.each do |space_type|
      # Loop through all spaces of current space type
      v_current_spaces = space_type.spaces
      next if not v_current_spaces.size > 0
      v_current_spaces.each do |current_space|
        occ_type_val = runner.getStringArgumentValue("Space_#{i}_" + current_space.nameString, user_arguments)
        occ_type_arg_vals[current_space.nameString] = occ_type_val
        i += 1
      end
    end


    all_args = [space_type_arg_vals, occ_type_arg_vals]
    # Read obXML file and call obFMU.exe
    # For now, we assume obXML is generated in the same path under ./OSimulator_out
    output_path = obFMU_path + 'OccSimulator_out'
    xml_path = obFMU_path + 'XMLs/' # where the obXMl and coSimXML files are stored
    xml_file_name = xml_path + "obXML.xml"
    co_sim_file_name = xml_path + "obCoSim.xml"
    output_file_name = output_path + "/OccSch_out"


    # Generate obXML and coSimXML files
    # Read user library
    userLib = UserLibrary.new(obFMU_path + "library.csv")
    obXML_builder(model, userLib, xml_path, all_args)
    coSimXML_builder(xml_path)

    # Command to call obFMU.exe
    system(obFMU_path + 'obFMU.exe', xml_file_name, output_file_name, co_sim_file_name)

    runner.registerInfo("Occupancy schedule simulation successfully completed.")

    # Read schedule file from csv
    # Update: Han Li 2018/9/14
    



    # report final condition of model
    runner.registerFinalCondition("End.")

    return true

  end

end

# register the measure to be used by the application
OccSim_integration.new.registerWithApplication
