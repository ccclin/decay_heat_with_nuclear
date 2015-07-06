class HashWithThermalFission
  attr_accessor :thermal_fission

  def initialize(init_data = 0)
    @thermal_fission = Hash.new  
    ary = [:U235, :Pu239, :U238]
    ary.each{|a| @thermal_fission[a] = init_data}
  end
end
