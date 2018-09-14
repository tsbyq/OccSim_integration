
solver_path = 'C:/Users/Han/OpenStudio/Measures/OccSim_v2/resources'
output_path = 'C:/Users/Han/OpenStudio/Measures/OccSim_v2/resources/OccSimulator_out/working_files'

xml_file_name = output_path + "/obXML.xml"
output_file_name = output_path + "/output"
co_sim_file_name = output_path + "/obCoSim.xml"

# Step 1
system(solver_path + '/obFMU.exe', xml_file_name, output_file_name, co_sim_file_name)