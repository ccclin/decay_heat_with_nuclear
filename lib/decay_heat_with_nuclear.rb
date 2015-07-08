require 'decay_heat_with_nuclear/version'
require 'decay_heat_with_nuclear/thermal_data'
require 'decay_heat_with_nuclear/tools'
require 'decay_heat_with_nuclear/main_run'

module DecayHeatWithNuclear
  def self.run(hash)
    test1 = MainRun::RunAns1979.new(hash)
    test2 = MainRun::RunASB9_2.new(hash)
    test3 = MainRun::RunAns1973.new(hash)

    {
      ans1979: test1.run,
      ans1973: test3.run,
      asb9_2:  test2.run
    }
  end
end
