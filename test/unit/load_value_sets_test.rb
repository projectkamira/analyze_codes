require_relative '../test_helper'

class LoadValueSetsTest < Test::Unit::TestCase

  def setup
  end
  
  def test_load_sets_from_dir
    value_sets = AnalyzeCodes.load_value_sets('./test/fixtures')
    value_sets.length.must_equal 2
  end
end
