require "bundler/gem_tasks"
require 'rake'
require 'rake/testtask'
require_relative 'lib/analyze_codes'

namespace :codes do
  desc 'Analyze values sets for intersection with patient data code counts'
  task :analyze, [:value_set_dir, :code_count_file] do |t, args|
    puts "Loading value sets from #{args.value_set_dir}"
    value_sets = AnalyzeCodes.load_value_sets(args.value_set_dir)
    puts "Loading codes from #{args.code_count_file}"
    all_codes_found = AnalyzeCodes.load_found_codes(args.code_count_file)
    puts "Analyzing intersection"
    intersection = AnalyzeCodes.analyze_value_sets(value_sets, all_codes_found)
    puts JSON.pretty_generate(intersection)
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
