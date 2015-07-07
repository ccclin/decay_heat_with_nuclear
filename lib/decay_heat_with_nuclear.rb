require 'decay_heat_with_nuclear/version'
Dir['data/*.rb'].each { |file| require file }
Dir['run/*.rb'].each { |file| require file }
Dir['tool/*.rb'].each { |file| require file }

# class DecayHeatWithNuclear
#   class << self
#     def run(hash)
#       test1 = RunAns1979.new(hash, 0)
#       test2 = RunASB9_2.new(hash, 0)
#       test3 = RunAns1973.new(hash, 0)

#       output = {
#         ans1979: test1.run,
#         ans1973: test3.run,
#         asb9_2:  test2.run
#       }
#     end
#   end
# end
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
