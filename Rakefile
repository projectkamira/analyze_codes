require "bundler/gem_tasks"
require 'rake'
require 'rake/testtask'
require_relative 'lib/analyze_codes'

namespace :codes do
  desc 'Analyze values sets and measures for intersection with patient data code counts'
  task :analyze, [:bundle_dir, :code_count_file] do |t, args|
    measure_dir = File.join(args.bundle_dir, 'measures', 'ep')
    puts "Loading measures from #{measure_dir}"
    measures = AnalyzeMeasures.load_measures(measure_dir)
    measure_dir = File.join(args.bundle_dir, 'measures', 'eh')
    puts "Loading measures from #{measure_dir}"
    measures.concat AnalyzeMeasures.load_measures(measure_dir)
    
    value_set_dir = File.join(args.bundle_dir, 'value_sets', 'xml')
    puts "Loading value sets from #{value_set_dir}"
    value_sets = AnalyzeValueSets.load_value_sets(value_set_dir)
    
    puts "Loading codes from #{args.code_count_file}"
    all_codes_found = AnalyzeValueSets.load_found_codes(args.code_count_file)
    
    puts "Analyzing value set intersections"
    value_set_intersection = AnalyzeValueSets.analyze_value_sets(value_sets, all_codes_found)
    puts "Analyzing measure intersections"
    measure_intersection = AnalyzeMeasures.analyze_measures(measures, value_set_intersection)
    
    puts "Writing results to ./tmp"
    out_dir = File.join(".", "tmp")
    ts = Time.now.strftime("%Y%m%d-%H%M%S")
    FileUtils.mkdir_p out_dir
    
    File.open(File.join(out_dir, "vs%s.json" % ts), 'w') do |f|
      f.write(JSON.pretty_generate(value_set_intersection))
    end
    File.open(File.join(out_dir, "measure%s.json" % ts), 'w') do |f|
      f.write(JSON.pretty_generate(measure_intersection))
    end
    arr = AnalyzeValueSets.as_2d_array(value_set_intersection)
    csv = CSV.generate(:force_quotes => false, :headers => :first_row) do |csv|
      arr.each do |value|
        csv << value
      end
    end
    File.open(File.join(out_dir, "vs%s.csv" % ts), 'w') do |f|
      f.write(csv)
    end
    arr = AnalyzeMeasures.as_2d_array(measure_intersection)
    csv = CSV.generate(:force_quotes => false, :headers => :first_row) do |csv|
      arr.each do |value|
        csv << value
      end
    end
    File.open(File.join(out_dir, "measure%s.csv" % ts), 'w') do |f|
      f.write(csv)
    end
  end
end

namespace :cover_me do
  task :report do
    require 'cover_me'
    CoverMe.complete!
  end
end

$LOAD_PATH << File.expand_path("../test",__FILE__)
desc "Run basic tests"
Rake::TestTask.new("test_units") { |t|
  t.pattern = 'test/unit/*_test.rb'
  t.verbose = true
  t.warning = false
}

task :default => [:test_units,'cover_me:report']
