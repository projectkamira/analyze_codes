module AnalyzeValueSets

  # Analyze value sets for intersection with patient data
  # @param [HealthDataStandards::SVS::ValueSet[]] value_sets
  # @param [{}] all_codes_found as map of {codeSetOID => {code => count}}
  # @param [Measure] all measures
  # @return [{}] map of {valueSetOID => {:totalCodes => count, :codesFound => count}}
  def self.analyze_value_sets(value_sets, all_codes_found, measures)
    result = {}
    value_sets.each do |value_set|
      intersection = {
        :totalCodes => value_set.concepts.length,
        :codesFound => 0,
        :displayName => value_set.display_name,
        :version => value_set.version,
        :type => AnalyzeValueSets.type(value_set.oid, measures)
      }
      all_code_sets = {}
      value_set.concepts.each do |concept|
        all_code_sets[concept.code_system] = true
        if all_codes_found[concept.code_system] && all_codes_found[concept.code_system][concept.code]
          intersection[:codesFound]+=1
        end
      end
      intersection[:percentFound] = 100.0*intersection[:codesFound]/intersection[:totalCodes]
      intersection[:codeSets] = all_code_sets.keys.map{|e| HealthDataStandards::Util::CodeSystemHelper.code_system_for(e)}.join(';')
      result[value_set.oid] = intersection
    end
    result
  end
  
  # Return indication of where value set is used in supplied measures
  # @return Symbol :eh, :ep, :both, :none
  def self.type(oid, measures)
    used = :none
    measures.each do |measure|
      if measure.oids.include?(oid) && used != :both
        measure_type = measure.type.intern
        if used == :none
          used = measure_type
        elsif used != measure_type
          used = :both
        end
      end
    end
    used
  end
  
  def self.as_2d_array(result)
    arr = [[:valueSet, :totalCodes, :codesFound, :percentFound, :displayName, :type, :codeSets]]
    arr.concat(result.collect do |key, value|
      [key, value[arr[0][1]], value[arr[0][2]], value[arr[0][3]], value[arr[0][4]], value[arr[0][5]], value[arr[0][6]]]
    end.to_a)
  end
  
  def self.load_value_sets(dir)
    Dir.glob(File.join(dir,'*.xml')).collect do |value_set_file|
      HealthDataStandards::SVS::ValueSet.load_from_xml(Nokogiri::XML(File.new(value_set_file).read))
    end
  end

  def self.load_found_codes(found_codes_file)
    JSON.parse(File.new(found_codes_file).read)
  end
end
