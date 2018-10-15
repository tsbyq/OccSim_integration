# insert your copyright here

# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

# start the measure
class TestDirectory < OpenStudio::Measure::ModelMeasure
  # human readable name
  def name
    # Measure name should be the title case of the class name.
    return 'Test_Directory'
  end

  # human readable description
  def description
    return 'Test Drct'
  end

  # human readable description of modeling approach
  def modeler_description
    return 'Test Drct'
  end

  # define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Measure::OSArgumentVector.new

    return args
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # use the built-in error checking
    if !runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    runner.registerInfo("The current directory is '#{Dir.pwd}'")
    runner.registerInfo("The current file is '#{__FILE__}'")
    
    workflow = model.workflowJSON
    
    oswPath = ''
    if !workflow.oswPath.empty?
      oswPath = workflow.oswPath.get
    end
    
    absoluteFilePaths = []
    workflow.absoluteFilePaths.each do |p|
      absoluteFilePaths << p
    end
    absoluteFilePaths = absoluteFilePaths.join(', ')
    
    absoluteMeasurePaths = []
    workflow.absoluteMeasurePaths.each do |p|
      absoluteMeasurePaths << p
    end
    absoluteMeasurePaths = absoluteMeasurePaths.join(', ')
    
    seedFile = ''
    if !workflow.seedFile.empty?
      seedFile = workflow.seedFile.get
    end
    
    weatherFile = ''
    if !workflow.weatherFile.empty?
      weatherFile = workflow.weatherFile.get
    end
    
    runner.registerInfo("workflow.oswPath = '#{oswPath}'")
    runner.registerInfo("workflow.oswDir = '#{workflow.oswDir}'")
    # currently where ExternalFiles go, https://github.com/NREL/OpenStudio/blob/develop/openstudiocore/src/model/ExternalFile.cpp#L128
    runner.registerInfo("workflow.absoluteRootDir = '#{workflow.absoluteRootDir}'")
    runner.registerInfo("workflow.absoluteRunDir = '#{workflow.absoluteRunDir}'")
    runner.registerInfo("workflow.absoluteOutPath = '#{workflow.absoluteOutPath}'")
    runner.registerInfo("workflow.absoluteFilePaths = '#{absoluteFilePaths}'")
    runner.registerInfo("workflow.absoluteMeasurePaths = '#{absoluteMeasurePaths}'")
    runner.registerInfo("workflow.seedFile = '#{seedFile}'")
    runner.registerInfo("workflow.weatherFile = '#{weatherFile}'")
    
    return true
  end
end

# register the measure to be used by the application
TestDirectory.new.registerWithApplication
