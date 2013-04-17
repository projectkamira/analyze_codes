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
      AnalyzeMeasures.extract_code_counts!(intersection, measure.oids, value_set_results)
      [:population, :denominator, :numerator, :exclusions, :exceptions].each do |pop|
        if measure[pop.to_s]
          pop_intersection = {
            :totalCodes => 0,
            :codesFound => 0,
          }
          pop_value_sets = AnalyzeMeasures.extract_population_value_sets(measure[pop.to_s])
          AnalyzeMeasures.extract_code_counts!(pop_intersection, pop_value_sets, value_set_results)
          if pop_intersection[:totalCodes] > 0
            # ignore empty populations, e.g. a denom that just refs the ipp
            intersection[pop] = pop_intersection
          end
        end
      end
      result[measure.id] = intersection
    end
    result
  end
  
  def self.process_item!(item, value_sets)
    if item['conjunction']
      item['items'].each do |child_item|
        AnalyzeMeasures.process_item!(child_item, value_sets)
      end
    else
      if item['code_list_id']
        value_sets.push item['code_list_id']
      end
      if item['temporal_references']
        item['temporal_references'].each do |ref|
          if ref['reference']
            AnalyzeMeasures.process_item!(ref['reference'], value_sets)
          end
        end
      end
    end
  end
  
  def self.extract_population_value_sets(population)
    value_sets = []
    AnalyzeMeasures.process_item!(population, value_sets)
    value_sets
  end
  
  def self.extract_code_counts!(intersection, value_sets, value_set_results)
    intersection[:valueSetCount] = value_sets.length
    redundant_value_sets = value_sets.select {|value_set| !value_set_results[value_set] || value_set_results[value_set][:codesFound] == 0}
    intersection[:redundantValueSetCount] = redundant_value_sets.length
    intersection[:redundantValueSets] = redundant_value_sets
    value_sets.each do |value_set|
      if value_set_results[value_set]
        intersection[:totalCodes]+=value_set_results[value_set][:totalCodes]
        intersection[:codesFound]+=value_set_results[value_set][:codesFound]
      end
    end
    if intersection[:totalCodes] > 0
      intersection[:percentFound] = 100.0*intersection[:codesFound]/intersection[:totalCodes]
    else
      intersection[:percentFound] = 0.0
    end
  end
  
  def self.as_2d_array(result)
    arr = [[:measureId, :measureName, :population, :nqfId, :cmsId, :totalCodes, :codesFound, :percentFound, :valueSetCount, :redundantValueSetCount]]
    measure_summary_rows = result.collect do |measure_id, measure_result|
      [
        measure_id,
        measure_result[arr[0][1]],
        :all,
        measure_result[arr[0][3]],
        measure_result[arr[0][4]],
        measure_result[arr[0][5]],
        measure_result[arr[0][6]],
        measure_result[arr[0][7]],
        measure_result[arr[0][8]],
        measure_result[arr[0][9]]
      ]
    end.to_a
    arr.concat(measure_summary_rows)
    result.each do |measure_id, measure_result|
      [:population, :denominator, :numerator, :exclusions, :exceptions].each do |pop|
        if measure_result[pop]
          arr.insert(-1, [
              measure_id,
              measure_result[arr[0][1]],
              pop,
              measure_result[arr[0][3]],
              measure_result[arr[0][4]],
              measure_result[pop][arr[0][5]],
              measure_result[pop][arr[0][6]],
              measure_result[pop][arr[0][7]],
              measure_result[pop][arr[0][8]],
              measure_result[pop][arr[0][9]]
            ]
          )
        end
      end
    end
    arr
  end
  
  def self.load_measures(dir)
    Dir.glob(File.join(dir,'*.json')).collect do |measure_file|
      json = JSON.parse(File.new(measure_file).read, :max_nesting => false)
      HealthDataStandards::CQM::Measure.new(json)
    end
  end
end
