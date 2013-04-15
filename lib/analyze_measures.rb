module AnalyzeMeasures

  # Analyze measures for intersection with patient data by rolling up results for
  # value sets used by the measure
  # @param [HealthDataStandards::CQM::Measure[]] measures
  # @param [{}] value_set_results as map of {:totalCodes => count, :codesFound => count}}
  # @return [{}] map of {measureId => {:totalCodes => count, :codesFound => count}}
  def self.analyze_measures(measures, value_set_results)
    result = {}
    measures.each do |measure|
      intersection = {
        :totalCodes => 0,
        :codesFound => 0,
        :measureName => measure.name,
        :nqfId => measure.nqf_id,
        :cmsId => measure['cms_id']
      }
      measure.oids.each do |value_set|
        if value_set_results[value_set]
          intersection[:totalCodes]+=value_set_results[value_set][:totalCodes]
          intersection[:codesFound]+=value_set_results[value_set][:codesFound]
        end
      end
      intersection[:percentFound] = 100.0*intersection[:codesFound]/intersection[:totalCodes]
      result[measure.id] = intersection
    end
    result
  end
  
  def self.as_2d_array(result)
    arr = [[:measureId, :nqfId, :cmsId, :totalCodes, :codesFound, :percentFound, :measureName]]
    arr.concat(result.collect do |key, value|
      [key, value[arr[0][1]], value[arr[0][2]], value[arr[0][3]], value[arr[0][4]], value[arr[0][5]], value[arr[0][6]]]
    end.to_a)
  end
  
  def self.load_measures(dir)
    Dir.glob(File.join(dir,'*.json')).collect do |measure_file|
      json = JSON.parse(File.new(measure_file).read, :max_nesting => false)
      HealthDataStandards::CQM::Measure.new(json)
    end
  end
end
