require 'decay_heat_with_nuclear/version'
require './decay_heat_with_nuclear/thermal_data'
require './decay_heat_with_nuclear/tools'
require './decay_heat_with_nuclear/main_run.rb'

module DecayHeatWithNuclear
  def self.run(hash)
    test1 = RunAns1979.new(hash, 0)
    test2 = RunASB9_2.new(hash, 0)
    test3 = RunAns1973.new(hash, 0)

    {
      ans1979: test1.run,
      ans1973: test3.run,
      asb9_2:  test2.run
    }
  end
end
