require 'C:/openstudio-2.6.2/Ruby/openstudio'

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


model = loadOSM('small_office.osm')

workspace_translator = OpenStudio::EnergyPlus::ReverseTranslator.new()

workspace_obFMU_idf = OpenStudio::Workspace::load('C:/Users/Han/Documents/GitHub/OpenStudio_related/OccSim_integration/development/OccSim_test/OSM_2.6.2/OccSch_out_IDF.idf').get
# # Only keep schedule:file related objects



workspace_obFMU_idf.objects.each do |idf_object|
    if(['Schedule:Compact', 'ScheduleTypeLimits', 'Zone'].include? idf_object.iddObject.name)
        workspace_obFMU_idf.removeObject(idf_object.handle)
    end
end


# puts workspace_obFMU_idf

obFMU_osm_objects = workspace_translator.translateWorkspace(workspace_obFMU_idf)

temp_people_obFMU_osm = obFMU_osm_objects.objects[1].to_People.get
 
temp_people_model_osm = model.getPeoples

puts temp_people_obFMU_osm
puts temp_people_model_osm


model.removeObject(temp_people_model_osm[0].handle)

puts temp_people_obFMU_osm.setSpace(model.getSpaces[0])





# create people def and instance (def can be shared across instances)
people_def = OpenStudio::Model::PeopleDefinition.new(model)
people_inst = OpenStudio::Model::People.new(people_def)















# # obFMU_osm_objects.getScheduleCompact
# # obFMU_osm_objects.getScheduleTypeLimits
# # obFMU_osm_objects.getPeopleDefinition
# # obFMU_osm_objects.getPeople
# # obFMU_osm_objects.getExternalFile
# # obFMU_osm_objects.getScheduleFile
# pe = obFMU_osm_objects.getPeoples[0]

# # puts obFMU_osm_objects.getPeoples[0]
# # puts obFMU_osm_objects.getPeoples[0].resetSpace()
# # puts obFMU_osm_objects.getPeoples[0]
# # # puts obFMU_osm_objects.getPeoples[0].setSpace(new_space)

# puts pe
# puts pe.resetSpace
# puts pe
# puts pe.setSpace(new_space)
# puts pe