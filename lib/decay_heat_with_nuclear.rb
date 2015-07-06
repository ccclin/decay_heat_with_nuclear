require './text_to_array.rb'
require './run_ans_1979.rb'
require './run_ans_1973.rb'
require './run_asb_9_2.rb'

class DecayHeatWithNuclear
  class << self
    def run(hash)
      test1 = RunAns1979.new(hash, 0)
      test2 = RunASB9_2.new(hash, 0)
      test3 = RunAns1973.new(hash, 0)

      output = {
        ans1979: test1.run,
        ans1973: test3.run,
        asb9_2:  test2.run
      }
    end
  end
end
