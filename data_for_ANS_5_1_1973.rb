require './hash_with_thermal_fission.rb'

# ANS/ANSI-5.1-1973, Standard for Decay Heat.
class DataForANS_5_1_1973

  # attr_reader 

  def initialize()
  end

  # theAn is An in ANS/ANSI-5.1-1973.
  def theAn
    array = Array.new(11)

    array[0] = 0.598
    array[1] = 1.65
    array[2] = 3.1
    array[3] = 3.87
    array[4] = 2.33
    array[5] = 1.29
    array[6] = 0.462
    array[7] = 0.328
    array[8] = 0.17
    array[9] = 0.0865
    array[10] = 0.114

    return array
  end

  # thean is an in ANS/ANSI-5.1-1973.
  def thean
    array = Array.new(10)

    array[0] = 1.772E+00
    array[1] = 5.774E-01
    array[2] = 6.743E-02
    array[3] = 6.214E-03
    array[4] = 4.739E-04
    array[5] = 4.810E-05
    array[6] = 5.344E-06
    array[7] = 5.716E-07
    array[8] = 1.036E-07
    array[9] = 2.959E-08
    array[10] = 7.585E-10

    return array
  end
end
