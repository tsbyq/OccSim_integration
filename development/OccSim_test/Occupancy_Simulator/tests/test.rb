# require 'openstudio'
require 'C:/openstudio-2.7.0/Ruby/openstudio.rb'
require 'openstudio/ruleset/ShowRunnerOutput'
require 'minitest/autorun'
require_relative '../measure.rb'
require 'fileutils'

require 'openstudio-standards.rb'

class OccupancySimulatorTest < Minitest::Test

  # def create_model(building_type, vintage, climate_zone, osm_directory)
  #     model = OpenStudio::Model::Model.new
  #     @debug = false
  #     epw_file = 'Not Applicable'
  #     prototype_creator = Standard.build("#{vintage}_#{building_type}")
  #     prototype_creator.model_create_prototype_model(climate_zone, epw_file, osm_directory, @debug, model)
  # end

  # def setup
  #   # Create a small office reference model for the testing
  #   path = File.dirname(__FILE__)
  #   building_type = 'SmallOffice'
  #   vintage = '90.1-2004'
  #   climate_zone = 'ASHRAE 169-2006-1A'
  #   osm_directory = path
  #   create_model(building_type, vintage, climate_zone, osm_directory)

  #   # Move the mocdel to the test main folder
  #   FileUtils.mv(path + '/SR1/in.osm', path + '/test_model.osm')
  #   FileUtils.mv(path + '/SR1/in.idf', path + '/test_model.idf')
  #   FileUtils.mv(path + '/SR1/in.epw', path + '/test_model.epw')
  #   FileUtils.rm_rf(path + '/SR1')
  # end

  # def teardown
  # end


  def test_argument_size_and_default_values
    # load the test model generated in the setup
    translator = OpenStudio::OSVersion::VersionTranslator.new
    path = File.dirname(__FILE__)
    path = OpenStudio::Path.new(File.dirname(__FILE__) + "/test_model.osm")
    model = translator.loadModel(path)
    assert((not model.empty?))
    model = model.get

    # create an instance of the measure
    measure = OccupancySimulator.new

    # get arguments and test that they are what we are expecting
    arguments = measure.arguments(model)
    argument_map = OpenStudio::Measure::convertOSArgumentVectorToMap(arguments)
    
    # Test the size of the arguments
    assert_equal(6, arguments.size)

    # Test the default values of the arguments
    args_hash = {}
    args_hash['Space_1_Perimeter_ZN_1'] = 'Office Type 1'
    args_hash['Space_2_Perimeter_ZN_2'] = 'Office Type 1'
    args_hash['Space_3_Perimeter_ZN_3'] = 'Office Type 1'
    args_hash['Space_4_Perimeter_ZN_4'] = 'Office Type 1'
    args_hash['Space_5_Core_ZN'] = 'Office Type 1'
    args_hash['Space_6_Attic'] = 'Other'
    arguments.each do |arg|
      arg_temp = arg.clone
      if args_hash[arg.name]
        assert(arg_temp.setValue(args_hash[arg.name]))
      end
      argument_map[arg.name] = arg_temp
    end
  end

  def test_measure_run
    # load the test model generated in the setup
    translator = OpenStudio::OSVersion::VersionTranslator.new
    path = File.dirname(__FILE__)
    path = OpenStudio::Path.new(File.dirname(__FILE__) + "/test_model.osm")
    model = translator.loadModel(path)
    assert((not model.empty?))
    model = model.get

    # create an instance of the measure
    measure = OccupancySimulator.new
    # create an instance of a runner
    runner = OpenStudio::Ruleset::OSRunner.new

    # get arguments and test that they are what we are expecting
    arguments = measure.arguments(model)
    argument_map = OpenStudio::Measure::convertOSArgumentVectorToMap(arguments)
    assert(measure.run(model, runner, argument_map))

    result = runner.result
    show_output(result)
  end

end