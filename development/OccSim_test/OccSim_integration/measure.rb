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

    # Read user pre-defined library
    root_path = File.dirname(__FILE__) + '/resources/'
    # Load reauired class and gem files
    load root_path + 'UserLibrary.rb'
    userLib = UserLibrary.new(root_path + "library.csv")

    # the name of the space to add to the model

    # Space type choices
    space_type_chs = OpenStudio::StringVector.new
    office_space_type_chs = OpenStudio::StringVector.new
    meeting_space_type_chs = OpenStudio::StringVector.new
    other_space_type_chs = OpenStudio::StringVector.new

    office_space_type_chs << userLib.Office_t1_name
    office_space_type_chs << userLib.Office_t2_name
    office_space_type_chs << userLib.Office_t3_name
    office_space_type_chs << userLib.Office_t4_name
    office_space_type_chs << userLib.Office_t5_name
    meeting_space_type_chs << userLib.meetingRoom_t1_name
    meeting_space_type_chs << userLib.meetingRoom_t2_name
    meeting_space_type_chs << userLib.meetingRoom_t3_name
    meeting_space_type_chs << userLib.meetingRoom_t4_name
    meeting_space_type_chs << userLib.meetingRoom_t5_name
    other_space_type_chs << "Auxiliary"
    other_space_type_chs << "Lobby"
    other_space_type_chs << "Corridor"
    other_space_type_chs << "Other"
    other_space_type_chs << "Plenum"

    # v_spaces = Array.new()
    # v_spaces = model.getSpaces
    v_space_types = model.getSpaceTypes

    # Standard space types for office rooms
    v_office_space_types = [
      'WholeBuilding - Sm Office',
      'WholeBuilding - Md Office',
      'WholeBuilding - Lg Office',
      'Office',
      'ClosedOffice',
      'OpenOffice',
      'SmallOffice - ClosedOffice',
      'SmallOffice - OpenOffice'
    ]
    # Standard space types for meeting rooms
    v_conference_space_types = [
      'Conference',
      'SmallOffice - Conference',
    ]
    # Standard space types for auxiliary rooms
    v_auxiliary_space_types = [
      'OfficeLarge Data Center',
      'OfficeLarge Main Data Center',
      'SmallOffice - Elec/MechRoom',
    ]
    v_other_space_types = [
      'Office Attic', 
      'Attic', 
      'Plenum Space Type',
      'SmallOffice - Corridor',
      'SmallOffice - Lobby',
      'SmallOffice - Attic',
      'SmallOffice - Restroom',
      'SmallOffice - Stair',
      'SmallOffice - Storage',
      ''
    ]

    i = 1
    # Loop through all space types, group spaces by their types
    v_space_types.each do |space_type|
      # Loop through all spaces of current space type
      # Puplate the valid options for each space depending on its space type
      if v_office_space_types.include? space_type.standardsSpaceType.to_s
        space_type_chs = office_space_type_chs
      elsif v_conference_space_types.include? space_type.standardsSpaceType.to_s
        space_type_chs = meeting_space_type_chs
      elsif v_other_space_types.include? space_type.standardsSpaceType.to_s
        space_type_chs = other_space_type_chs
      # else
      #   space_type_chs = other_space_type_chs
      end

      v_current_spaces = space_type.spaces
      next if not v_current_spaces.size > 0
      v_current_spaces.each do |current_space|

        arg_temp = OpenStudio::Measure::OSArgument::makeChoiceArgument("Space_#{i}_" + current_space.nameString, space_type_chs, true)
        arg_temp.setDisplayName("Space #{i}: " + current_space.nameString)
        # Conditionally set the default choice for the space
        if(v_office_space_types.include? space_type.standardsSpaceType.to_s)
          arg_temp.setDefaultValue(userLib.Office_t1_name)
        elsif(v_conference_space_types.include? space_type.standardsSpaceType.to_s)
          arg_temp.setDefaultValue(userLib.meetingRoom_t1_name)
        elsif(v_auxiliary_space_types.include? space_type.standardsSpaceType.to_s)
          arg_temp.setDefaultValue('Auxiliary')
        elsif(v_other_space_types.include? space_type.standardsSpaceType.to_s)
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

  # Primary function, build a obXML from OpenStudio model and pre-defined library
  # @param osModel [OpenStudio::Model::Model]
  # @param userLib [UserLibrary]
  #
  # @return [type] [description]
def obXML_builder(osModel, userLib, outPath, all_args)
    # Get general information ----------------------------------------------------
    # Get specific occupancy assumptions for each space
    flag_space_occ_choice = all_args[0]
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
    v_holidays = [
      userLib.usHolidayNewYearsDay,
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
      userLib.customHolidayCustomHoliday_5
    ]

    # Consider the space to be an office space if the space type is in the list
    v_office_space_types = [
      'WholeBuilding - Sm Office',
      'WholeBuilding - Md Office',
      'WholeBuilding - Lg Office',
      'Office',
      'ClosedOffice',
      'OpenOffice',
      'SmallOffice - ClosedOffice',
      'SmallOffice - OpenOffice'
    ]

    # Consider the space to be a conference space is the type is in the list
    v_conference_space_types = [
      'Conference',
      'SmallOffice - Conference',
      'MediumOffice - Conference'
    ]

    # Loop through all space types
    v_space_types.each do |space_type|
      # puts space_type.standardsSpaceType.to_s
      if v_office_space_types.include? space_type.standardsSpaceType.to_s
        # Add the corresponding office spaces to the array
        v_officeSpaces += space_type.spaces
      elsif v_conference_space_types.include? space_type.standardsSpaceType.to_s
        # Add the corresponding conference spaces to the array
        v_meetingSpaces += space_type.spaces
      end
    end

    # Number of space and number of people
    n_space = v_officeSpaces.length
    n_occ = 0
    n_occ_hash = Hash.new
    v_officeSpaces.each do |officeSpace|
      space_type_selected = flag_space_occ_choice[officeSpace.name.to_s]
      n_occ_current = (officeSpace.floorArea / space_rules[space_type_selected]['OccupancyDensity']).floor
      n_occ += n_occ_current
      # Save the maximum number of people to a hash
      n_occ_hash[officeSpace.name.to_s] = n_occ_current
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

    # Create a hash to store the space and index
    space_ID_map = Hash.new

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

      # Assign the space id and name, and save it to the hash
      spaceIDString = "S#{index + 1 + all_index}_#{meetingSpaceName}"
      space_ID_map[meetingSpaceName] = index + 1 + all_index
      n_occ_hash[meetingSpace.nameString] = max_occupant_per_meeting

      f.puts("<Space ID='" + spaceIDString + "'>")
      f.puts("<Type>MeetingRoom</Type>")
      f.puts("<MeetingEvent>")
      f.puts("<SeasonType>All</SeasonType>")
      f.puts('<DayofWeek>Weekdays</DayofWeek>')
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

      # Assign the space id and name, and save it to the hash
      spaceIDString = "S#{index + 1 + all_index}_#{officeSpaceName}"
      space_ID_map[officeSpaceName] = index + 1 + all_index

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

    result_hashes = [space_ID_map, n_occ_hash]
    return result_hashes

  end

  # This function build a CoSimXMl.xml file
  # All the fields are default
  def coSimXML_builder(model, outPath)

    # Get simulation configurations from model
    if model.isLeapYear
      isLeapYear = 'Yes'
    else
      isLeapYear = 'No'
    end
    dayofWeekforStartDay = model.dayofWeekforStartDay
    beginMonth = model.runPeriod.get.getBeginMonth
    beginDayOfMonth = model.runPeriod.get.getBeginDayOfMonth
    endMonth = model.runPeriod.get.getEndMonth
    endDayOfMonth = model.runPeriod.get.getEndDayOfMonth
    timestepsPerHour = model.getTimestep.numberOfTimestepsPerHour

    # Write XML to file
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
    f.puts('<IsLeapYear>' + isLeapYear + '</IsLeapYear>')
    f.puts('<DayofWeekForStartDay>' + dayofWeekforStartDay.to_s + '</DayofWeekForStartDay>')
    f.puts('<IsDebugMode>No</IsDebugMode>')
    f.puts('<DoMovementCalculation>Yes</DoMovementCalculation>')
    f.puts('<StartMonth>' + beginMonth.to_s + '</StartMonth>')
    f.puts('<StartDay>' + beginDayOfMonth.to_s + '</StartDay>')
    f.puts('<EndMonth>' + endMonth.to_s + '</EndMonth>')
    f.puts('<EndDay>' + endDayOfMonth.to_s + '</EndDay>')
    f.puts('<NumberofTimestepsPerHour>' + timestepsPerHour.to_s + '</NumberofTimestepsPerHour>')
    f.puts('</SimulationSettings>')
    ## --Simulation setting
    f.puts('</CoSimulationParameters>')
    # --CoSimulationParameters
    f.close

    puts 'coSimXML.xml file created.'
  end


  def get_os_schedule_from_csv(file_name, model, col, skip_row)
    file_name = File.realpath(file_name)
    external_file = OpenStudio::Model::ExternalFile::getExternalFile(model, file_name)
    external_file = external_file.get
    schedule_file = OpenStudio::Model::ScheduleFile.new(external_file, col, skip_row)
    # schedule_type_limit = OpenStudio::Model::ScheduleTypeLimits .new(model)
    # schedule_file.setScheduleTypeLimits(schedule_type_limit)
    return schedule_file
  end

  def set_schedule_for_people(model, space_name, csv_file, userLib, all_args)
    space_rules = space_rule_hash_wrapper(userLib)
    occ_type_arg_vals = all_args[0]
    space_ID_map = all_args[1]
    n_occ_hash = all_args[2]
    space_type_selected = occ_type_arg_vals[space_name]

    # puts space_name

    # Only office and meeting spaces have space rules for now
    if not space_rules[space_type_selected].nil?

      # For testing
      puts '******'
      puts space_name
      puts n_occ_hash[space_name]

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

      # Check if the space is office or meeting room.
      if space_rules[space_type_selected]['OccupancyDensity'].nil?
        # The current space is a meeting room
        # n_people = space_rules[space_type_selected]['MaximumNumberOfPeoplePerMeeting']

        n_people = n_occ_hash[space_name]
        new_people_def.setNumberOfPeopleCalculationMethod('People', 1)
        new_people_def.setNumberofPeople(n_people)
      else
        # The current space is a office room
        # people_per_area = 1.0/space_rules[space_type_selected]['OccupancyDensity'] # reciprocal of area/person in the user defined library
        # new_people_def.setNumberOfPeopleCalculationMethod('People/Area', 1)

        n_people = n_occ_hash[space_name]
        new_people_def.setNumberOfPeopleCalculationMethod('People', 1)
        new_people_def.setNumberofPeople(n_people)
        # new_people_def.setPeopleperSpaceFloorArea(people_per_area)

        # puts people_per_area
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


  ##############################################################################
  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # use the built-in error checking
    if !runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    # report initial condition of model
    runner.registerInitialCondition("Start.")

    # get current file directory
    model_temp_run_path = Dir.pwd + '/'
    model_temp_measure_path = File.expand_path("../../..", model_temp_run_path) + '/resources/measures/OccSim_integration/'
    model_temp_resources_path =File.expand_path("../../..", model_temp_run_path) + '/resources/'

    runner.registerInfo("The temp run directory is '#{model_temp_run_path}'")
    obFMU_path = File.dirname(__FILE__) + '/resources/'
    runner.registerInfo("obFMU_path is '#{obFMU_path}'")

    runner.registerInfo("The temp measure directory is '#{model_temp_measure_path}'")
    runner.registerInfo("The temp resources directory is '#{model_temp_resources_path}'")

    # Load reauired class
    if File.directory?(model_temp_measure_path + 'resources')
      load model_temp_measure_path + 'resources/UserLibrary.rb'
      userLib = UserLibrary.new(model_temp_measure_path + "resources/library.csv")
    else
      load obFMU_path + 'UserLibrary.rb'
      userLib = UserLibrary.new(obFMU_path + "library.csv")
    end

    # ### Get user input for whether to use default assumptions by space types
    v_space_types = model.getSpaceTypes


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

    all_args = []
    all_args[0] = occ_type_arg_vals

    # Read obXML file and call obFMU.exe
    # For now, we assume obXML is generated in the same path under ./OSimulator_out
    output_path = obFMU_path + 'OccSimulator_out'
    xml_path = obFMU_path  # where the obXMl and coSimXML files are stored
    xml_file_name = xml_path + "obXML.xml"
    co_sim_file_name = xml_path + "obCoSim.xml"

    # Change this to the temp path (Dir)
    output_file_name = output_path

    # Generate obXML and coSimXML files
    result_hashes = obXML_builder(model, userLib, xml_path, all_args)
    coSimXML_builder(model, xml_path)

    # Command to call obFMU.exe
    system(obFMU_path + 'obFMU.exe', xml_file_name, output_file_name, co_sim_file_name)
    runner.registerInfo("Occupancy schedule simulation successfully completed.")
    # Move the file to the temp folder
    external_csv_path_old = output_file_name + '_IDF.csv'
    external_csv_path_new = model_temp_resources_path + external_csv_path_old.split('/')[-1]


    runner.registerInfo("The old output occ sch file is at '#{external_csv_path_old}'")
    runner.registerInfo("We want to move it to '#{model_temp_resources_path}'")

    # Important, copy the output csv from the obFMU path
    FileUtils.cp(output_file_name + '_IDF.csv', model_temp_resources_path)

    runner.registerInfo("Occupancy schedule files copied to the temporary folder: #{model_temp_run_path}.")

    # Read schedule file from csv
    # Update: Han Li 2018/9/14
    # Read schedule back to osm
    runner.registerInfo("Reading stochastic occupancy schedule back to the osm.")

    space_ID_map = result_hashes[0]
    n_occ_hash = result_hashes[1]

    all_args[1] = space_ID_map
    all_args[2] = n_occ_hash


    # Remove all people object (if exist) in the old model
    model.getPeoples.each do |os_people|
      os_people.remove
    end

    model.getPeopleDefinitions.each do |os_people_def|
      os_people_def.remove
    end

    puts all_args[2]

    # Add schedule:file to model
    model.getSpaces.each do |space|
      model = set_schedule_for_people(model, space.name.to_s, external_csv_path_new, userLib, all_args)
    end

    runner.registerInfo("Occupancy schedule updated.")
    # report final condition of model

    runner.registerFinalCondition("End.")

    return true

  end

end

# register the measure to be used by the application
OccSim_integration.new.registerWithApplication
