# insert your copyright here

# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

# start the measure
class CreateSWHSchedule < OpenStudio::Measure::ModelMeasure
  # human readable name
  def name
    # Measure name should be the title case of the class name.
    return 'Create Service Water Heating Schedule'
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

    return args
  end

  def update_water_use_equip(model, schedule)
    # Set the water use equipment schedule to the OS:WaterUse:Equipment objects
    v_water_use_equips = model.getWaterUseEquipments
    v_water_use_equips.each do |water_use_equip|
      water_use_equip.setFlowRateFractionSchedule(schedule)
    end
    return model
  end


  def get_os_schedule_from_csv(model, file_name, schedule_name, col, skip_row=0)
    # This function creates an OS:Schedule:File from a CSV at specified position
    file_name = File.realpath(file_name)
    external_file = OpenStudio::Model::ExternalFile::getExternalFile(model, file_name)
    external_file = external_file.get
    schedule_file = OpenStudio::Model::ScheduleFile.new(external_file, col, skip_row)
    schedule_file.setName(schedule_name)
    return schedule_file
  end


  def vcols_to_csv(v_cols, file_name='sch_swh.csv')
    # This function write an array of columns(arrays) into a CSV.
    # The first element of each column array is treated as the header of that column
    # Note: the column arrays in the v_cols should have the same length
    nrows = v_cols[0].length
    CSV.open(file_name, 'wb') do |csv|
      0.upto(nrows-1) do |row|
        v_row = Array.new()
        v_cols.each do |v_col|
          v_row << v_col[row]
        end
        csv << v_row
      end
    end
    puts 'Done!'
  end

  def get_weighted_fraction(frac, v_occ_frac)
    v_temp = Array.new
    v_occ_frac.each_with_index do |frac_timestamp, i|
      v_temp[i] = frac * frac_timestamp.to_f
    end
    return v_temp
  end


  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # use the built-in error checking
    if !runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    runner.registerInfo("Start to create new service water heating schedule from occupant count schedule")

    ### get file directories
    model_temp_run_path = Dir.pwd + '/'
    model_temp_resources_path =File.expand_path("../../..", model_temp_run_path) + '/resources/' # where the occupancy schedule will be saved

    csv_file = model_temp_resources_path + '/files/OccSimulator_out_IDF.csv' # ! Need to update this CSV filename if it's changed in the occupancy simulator



    # Get the spaces with occupancy count schedule available
    v_spaces_occ_sch = File.readlines(csv_file)[3].split(',') # Room ID is saved in 4th row of the occ_sch file
    v_headers = Array.new
    v_spaces_occ_sch.each do |space_occ_sch|
      if (!['Room ID', 'S0_Outdoor', 'Outside building'].include? space_occ_sch and !space_occ_sch.strip.empty?)
          v_headers << space_occ_sch
      end
    end
    v_headers = ["Time"] + v_headers

    # Read the occupant count schedule file and clean it
    clean_csv = File.readlines(csv_file).drop(6).join
    csv_table_sch = CSV.parse(clean_csv, headers:true)
    new_csv_table = csv_table_sch.by_col!.delete_if do |column_name, column_values|
      !v_headers.include? column_name
    end
    runner.registerInfo("Pre-processing completed.")

    v_spaces = model.getSpaces
    # Get the maximum total number of people in the building and each space
    n_occ_bldg = 0
    n_occ_space_hash = Hash.new
    v_spaces.each do |space|
      n_occ_bldg += space.numberOfPeople
      n_occ_space_hash[space.nameString] = space.numberOfPeople
    end

    # Create the new fraction schedule for SWH
    swh_fraction = 0
    v_vfracs = Array.new
    v_headers.each do |header|
      if header != 'Time'
        space_name = header
        space_name_model = header.partition('_').last # Get rid of the prefix (e.g., S1_)
        v_occ_fraction = new_csv_table.by_col![space_name]
        occ_frac = n_occ_space_hash[space_name_model] / n_occ_bldg
        v_temp = get_weighted_fraction(occ_frac, v_occ_fraction)
        v_vfracs.push(v_temp)
      end
    end

    # Assemble the whole building occupant faraction array from the weighted space fraction arrays
    v_occ_frac_bldg = Array.new
    v_vfracs.each_with_index do |v_frac, j|
      v_frac.each_with_index do |frac_timestamp, i|
        if j == 0
          v_occ_frac_bldg[i] = frac_timestamp
        else
          v_occ_frac_bldg[i] += frac_timestamp
        end
      end
    end
    runner.registerInfo("Whole building occupant fraction schedule CSV file generated.")

    # Code to generate new SWH schedule from the whole building occupant fraction schedule goes here.
    # <place-holder>
    runner.registerInfo("New service water heating flow rate schedule generated.")

    # Write the whole building occupant count fraction schedule to CSV
    schedule_csv_name='sch_swh.csv'
    vcols_to_csv([v_occ_frac_bldg], file_name=schedule_csv_name)

    # Add schedule file back to the model
    sch_swh = get_os_schedule_from_csv(model, schedule_csv_name, 'New SWH sch', col=1, skip_row=0)
    sch_swh.setMinutesperItem('10')
    model = update_water_use_equip(model, sch_swh)
    runner.registerInfo("New service water heating flow rate schedule added to the model.")


    # report final condition of model
    runner.registerFinalCondition("Finished.")

    return true
  end
end

# register the measure to be used by the application
CreateSWHSchedule.new.registerWithApplication
