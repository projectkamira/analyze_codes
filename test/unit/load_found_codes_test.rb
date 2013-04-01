require_relative '../test_helper'

class LoadFoundCodesTest < Test::Unit::TestCase

  def setup
  end
  
  def test_load_found_codes
    codes = AnalyzeCodes.load_found_codes('./test/fixtures/codes_found.json')
    codes["2.16.840.1.113883.6.96"].wont_equal nil
    codes["2.16.840.1.113883.6.96"]["1234567890"].must_equal 1
  end
end
