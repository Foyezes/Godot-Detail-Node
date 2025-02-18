@tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeDetail

func _get_name():
	return "Detail"
func _get_category():
	return "Color"
func _get_description():
	return "Blend a secondary albedo and normal map & add more detail"
func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR_3D
func _get_input_port_count():
	return 6
func _get_input_port_name(port):
	match port:
		0:
			return "Albedo Base"
		1:
			return "Albedo Detail"
		2:
			return "Normal Base"
		3:
			return "Normal Detail"
		4:
			return "Detail Normal Strength"
		5:
			return "Mask"
func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR_4D
		1:
			return VisualShaderNode.PORT_TYPE_VECTOR_4D
		2:
			return VisualShaderNode.PORT_TYPE_VECTOR_3D
		3:
			return VisualShaderNode.PORT_TYPE_VECTOR_3D
		4:
			return VisualShaderNode.PORT_TYPE_SCALAR
		5:
			return VisualShaderNode.PORT_TYPE_SCALAR
func _get_input_port_default_value(port):
	match port:
		4:
			return 1.0
		5:
			return 1.0
func _get_output_port_count():
	return 2
func _get_output_port_name(port):
	match port:
		0:
			return "Albedo"
		1:
			return "Normal"	
func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_VECTOR_3D
func _get_property_count():
	return 1
func _get_property_default_index(index):
	return 0
func _get_property_name(index):
	match index:
		0:
			return "Albedo Blend Mode"
func _get_property_options(index):
	return ["Mix", "Add", "Subtract", "Multiply"]
func _get_global_code(mode):
	var blendMode = get_option_index(0)
	match blendMode:
		0: #Mix
			return """
			vec3 albedoDetail(vec4 albedo_base_tex, vec4 albedo_detail_tex, float detail_mask){
				vec3 albedo_1 = mix(albedo_base_tex.rgb, albedo_detail_tex.rgb, albedo_detail_tex.r);
				vec3 albedo_2 = mix(albedo_base_tex.rgb, albedo_1.rgb, detail_mask);
				return albedo_2;
			}
			
			vec3 normalDetail(vec3 normal_base_tex, vec3 normal_detail_tex, float normal_strength_in, float detail_mask){
				vec3 normal_1 = vec3(normal_base_tex.rg + ((normal_detail_tex.rg - 0.5) * clamp(normal_strength_in, 0.0, 1.0)), normal_base_tex.z);
				return vec3(mix(normal_base_tex, normal_1, detail_mask));
			}
	"""
		1: #Add
			return """
			vec3 albedoDetail(vec4 albedo_base_tex, vec4 albedo_detail_tex, float detail_mask){
				vec3 albedo_1 = mix(albedo_base_tex.rgb, albedo_base_tex.rgb + albedo_detail_tex.rgb, albedo_detail_tex.a);
				return vec3(mix(albedo_base_tex.rgb, albedo_1.rgb, detail_mask));
				
			}
			
			vec3 normalDetail(vec3 normal_base_tex, vec3 normal_detail_tex, float normal_strength_in, float detail_mask){
				vec3 normal_1 = vec3(normal_base_tex.rg + ((normal_detail_tex.rg - 0.5) * clamp(normal_strength_in, 0.0, 1.0)), normal_base_tex.z);
				return vec3(mix(normal_base_tex, normal_1, detail_mask));
			}
		
	"""
		2: #Subtract
			return """
			vec3 albedoDetail(vec4 albedo_base_tex, vec4 albedo_detail_tex, float detail_mask){
				vec3 albedo_1 = mix(albedo_base_tex.rgb, albedo_base_tex.rgb - albedo_detail_tex.rgb, albedo_detail_tex.a);
				return vec3(mix(albedo_base_tex.rgb, albedo_1.rgb, detail_mask));
				
			}
			
			vec3 normalDetail(vec3 normal_base_tex, vec3 normal_detail_tex, float normal_strength_in, float detail_mask){
				vec3 normal_1 = vec3(normal_base_tex.rg + ((normal_detail_tex.rg - 0.5) * clamp(normal_strength_in, 0.0, 1.0)), normal_base_tex.z);
				return vec3(mix(normal_base_tex, normal_1, detail_mask));
			}
		
	"""
		3: #Multiply
			return """
			vec3 albedoDetail(vec4 albedo_base_tex, vec4 albedo_detail_tex, float detail_mask){
				vec3 albedo_1 = mix(albedo_base_tex.rgb, albedo_base_tex.rgb * albedo_detail_tex.rgb, albedo_detail_tex.a);
				return vec3(mix(albedo_base_tex.rgb, albedo_1.rgb, detail_mask));
				
			}
			
			vec3 normalDetail(vec3 normal_base_tex, vec3 normal_detail_tex, float normal_strength_in, float detail_mask){
				vec3 normal_1 = vec3(normal_base_tex.rg + ((normal_detail_tex.rg - 0.5) * clamp(normal_strength_in, 0.0, 1.0)), normal_base_tex.z);
				return vec3(mix(normal_base_tex, normal_1, detail_mask));
			}
		
	"""
func _get_code(input_vars, output_vars, mode, type):
	return output_vars[0] + "=albedoDetail(%s, %s, %s);" % [input_vars[0], input_vars[1], input_vars[4]] + output_vars[1] + "=normalize(normalDetail(%s, %s, %s, %s));" % [input_vars[2], input_vars[3], input_vars[4], input_vars[5]]
