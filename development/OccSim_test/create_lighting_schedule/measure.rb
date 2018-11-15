# insert your copyright here

# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

# require 'C:/openstudio-2.7.0/Ruby/openstudio.rb'
# start the measure
class CreateLightingSchedule < OpenStudio::Measure::ModelMeasure
  # human readable name
  def name
    # Measure name should be the title case of the class name.
    return 'Create Lighting Schedule'
  end

  # human readable description
  def description
    return 'Replace this text with an explanation of what the measure does in terms that can be understood by a general building professional audience (building owners, architects, engineers, contractors, etc.).  This description will be used to create reports aimed at convincing the owner and/or design team to implement the measure in the actual building design.  For this reason, the description may include details about how the measure would be implemented, along with explanations of qualitative benefits associated with the measure.  It is good practice to include citations in the measure if the description is taken from a known source or if specific benefits are listed.'
  end

  # human readable description of modeling approach
  def modeler_description
    return 'Replace this text with an explanation for the energy modeler specifically.  It should explain how the measure is modeled, including any requirements about how the baseline model must be set up, major assumptions, citations of references to applicable modeling resources, etc.  The energy modeler should be able to read this description and understand what changes the measure is making to the model and why these changes are being made.  Because the Modeler Description is written for an expert audience, using common abbreviations for brevity is good practice.'
  end

  # define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Measure::OSArgumentVector.new


    # Space type choices
    space_type_chs = OpenStudio::StringVector.new
    office_space_type_chs = OpenStudio::StringVector.new
    meeting_space_type_chs = OpenStudio::StringVector.new
    other_space_type_chs = OpenStudio::StringVector.new

    office_space_type_chs << "Open-plan office"
    office_space_type_chs << "Closed office"

    meeting_space_type_chs << "Conference room"

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
          arg_temp.setDefaultValue("Open-plan office")
        elsif(v_conference_space_types.include? space_type.standardsSpaceType.to_s)
          arg_temp.setDefaultValue("Conference room")
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

    puts '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    puts args[0].class
    puts args[0]
    puts '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'

    # # the name of the space to add to the model
    # space_name = OpenStudio::Measure::OSArgument.makeStringArgument('space_name', true)
    # space_name.setDisplayName('New space name')
    # space_name.setDescription('This name will be used as the name of the new space.')
    # args << space_name

    return args
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # use the built-in error checking
    if !runner.validateUserArguments(arguments(model), user_arguments)
      return false
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


    # report initial condition of model
    runner.registerInitialCondition("The building started with #{model.getSpaces.size} spaces.")


    # echo the new space's name back to the user
    # runner.registerInfo("Space #{new_space.name} was added.")

    # report final condition of model
    runner.registerFinalCondition("The building finished with #{model.getSpaces.size} spaces.")

    return true
  end
end

# register the measure to be used by the application
CreateLightingSchedule.new.registerWithApplication
