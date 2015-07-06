require 'hash_with_thermal_fission.rb'

# ANSI/ANS-5.1-1979, American National Standard for Decay
# Heat Power in Light Water Reactors.
class DataForANS_5_1_1979
  # phi is the number of fissions per initial fissile atoms.
  # tinf is t = inf, setting it 1.0E+13.
  # R(theR) is the nuber of U-239 atoms produced per fission.
  # lamda1 is decay constant for U239 and Np239.
  # lamda2 is decay constant for Np239.
  # theEU239 is average energy from decay of on U239 atom (0.474 MeV)
  # theENp239 is average energy from decay of on Np239 atom (0.419 MeV)
  attr_reader :phi, :tinf, :theR, :lamda1, :lamda2, :theEU239, :theENp239

  def initialize()
    @phi = 3.0
    @tinf = 1.0E+13
    @theR = 6.20E-01
    @lamda1 = 4.91E-04
    @lamda2 = 3.41E-06
    @theEU239 = 0.474
    @theENp239 = 0.419
  end

  # thePi is Pi in ANS-5.1-1979.
  def thePi
    hash = HashWithThermalFission.new

    hash.thermal_fission[:U235]  = 0.98
    hash.thermal_fission[:Pu239] = 0.01
    hash.thermal_fission[:U238]  = 0.01

    return hash.thermal_fission
  end

  # theQ is Q in ANS-5.1-1979.
  # Total recoverable energy assicuated with on fission of nuclide.
  # Default is 200 MeV/sec in U235, Pu239, U238 and others
  def theQ
    hash = HashWithThermalFission.new(200.0)
    hash.thermal_fission[:others] = 200.0
    return hash.thermal_fission
  end

  # theU235_alpha is alpha in ANS-5.1-1979 Table 7.
  def theU235_alpha
    array = Array.new(23)

    array[0] = 6.5057E-01
    array[1] = 5.1264E-01
    array[2] = 2.4384E-01
    array[3] = 1.3850E-01
    array[4] = 5.544E-02
    array[5] = 2.2225E-02
    array[6] = 3.3088E-03
    array[7] = 9.3015E-04
    array[8] = 8.0943E-04
    array[9] = 1.9567E-04
    array[10] = 3.2535E-05
    array[11] = 7.5595E-06
    array[12] = 2.5232E-06
    array[13] = 4.9948E-07
    array[14] = 1.8531E-07
    array[15] = 2.6608E-08
    array[16] = 2.2398E-09
    array[17] = 8.1641E-12
    array[18] = 8.7797E-11
    array[19] = 2.5131E-14
    array[20] = 3.2176E-16
    array[21] = 4.5038E-17
    array[22] = 7.4791E-17

    return array
  end

  # theU235_lamda is lamda in ANS-5.1-1979 Table 7.
  def theU235_lamda
    array = Array.new(23)

    array[0] = 2.2138E+01
    array[1] = 5.1587E-01
    array[2] = 1.9594E-01
    array[3] = 1.0314E-01
    array[4] = 3.3656E-02
    array[5] = 1.1681E-02
    array[6] = 3.5870E-03
    array[7] = 1.3930E-03
    array[8] = 6.2630E-04
    array[9] = 1.8906E-04
    array[10] = 5.4988E-05
    array[11] = 2.0958E-05
    array[12] = 1.0010E-05
    array[13] = 2.5438E-06
    array[14] = 6.6361E-07
    array[15] = 1.2290E-07
    array[16] = 2.7213E-08
    array[17] = 4.3714E-09
    array[18] = 7.5780E-10
    array[19] = 2.4786E-10
    array[20] = 2.2384E-13
    array[21] = 2.4600E-14
    array[22] = 1.5699E-14

    return array
  end

  # thePu239_alpha is alpha in ANS-5.1-1979 Table 8.
  def thePu239_alpha
    array = Array.new(23)

    array[0] = 2.083E-01
    array[1] = 3.853E-01
    array[2] = 2.213E-01
    array[3] = 9.460E-02
    array[4] = 3.531E-02
    array[5] = 2.292E-02
    array[6] = 3.946E-03
    array[7] = 1.317E-03
    array[8] = 7.052E-04
    array[9] = 1.432E-04
    array[10] = 1.765E-05
    array[11] = 7.347E-06
    array[12] = 1.747E-06
    array[13] = 5.481E-07
    array[14] = 1.671E-07
    array[15] = 2.112E-08
    array[16] = 2.996E-09
    array[17] = 5.107E-11
    array[18] = 5.730E-11
    array[19] = 4.138E-14
    array[20] = 1.088E-15
    array[21] = 2.454E-17
    array[22] = 7.557E-17

    return array
  end

  # thePu239_lamda is lamda in ANS-5.1-1979 Table 8.
  def thePu239_lamda
    array = Array.new(23)

    array[0] = 1.002E+01
    array[1] = 6.433E-01
    array[2] = 2.186E-01
    array[3] = 1.004E-01
    array[4] = 3.728E-02
    array[5] = 1.435E-02
    array[6] = 4.549E-03
    array[7] = 1.328E-03
    array[8] = 5.356E-04
    array[9] = 1.730E-04
    array[10] = 4.881E-05
    array[11] = 2.006E-05
    array[12] = 8.319E-06
    array[13] = 2.358E-06
    array[14] = 6.450E-07
    array[15] = 1.278E-07
    array[16] = 2.466E-08
    array[17] = 9.378E-09
    array[18] = 7.450E-10
    array[19] = 2.426E-10
    array[20] = 2.210E-13
    array[21] = 2.640E-14
    array[22] = 1.380E-14

    return array
  end

  # theU238_alpha is alpha in ANS-5.1-1979 Table 9.
  def theU238_alpha
    array = Array.new(23)

    array[0] = 1.2311E+0
    array[1] = 1.1486E+0
    array[2] = 7.0701E-01
    array[3] = 2.5209E-01
    array[4] = 7.187E-02
    array[5] = 2.8291E-02
    array[6] = 6.8382E-03
    array[7] = 1.2322E-03
    array[8] = 6.8409E-04
    array[9] = 1.6975E-04
    array[10] = 2.4182E-05
    array[11] = 6.6356E-06
    array[12] = 1.0075E-06
    array[13] = 4.9894E-07
    array[14] = 1.6352E-07
    array[15] = 2.3355E-08
    array[16] = 2.8094E-09
    array[17] = 3.6236E-11
    array[18] = 6.4577E-11
    array[19] = 4.4963E-14
    array[20] = 3.6654E-16
    array[21] = 5.6293E-17
    array[22] = 7.1602E-17

    return array
  end

  # theU238_lamda is lamda in ANS-5.1-1979 Table 9.
  def theU238_lamda
    array = Array.new(23)

    array[0] = 3.2881E+0
    array[1] = 9.3805E-01
    array[2] = 3.7073E-01
    array[3] = 1.1118E-01
    array[4] = 3.6143E-02
    array[5] = 1.3272E-02
    array[6] = 5.0133E-03
    array[7] = 1.3655E-03
    array[8] = 5.5158E-04
    array[9] = 1.7873E-04
    array[10] = 4.9032E-05
    array[11] = 1.7058E-05
    array[12] = 7.0465E-06
    array[13] = 2.3190E-06
    array[14] = 6.4480E-07
    array[15] = 1.2649E-07
    array[16] = 2.5548E-08
    array[17] = 8.4782E-09
    array[18] = 7.5130E-10
    array[19] = 2.4188E-10
    array[20] = 2.2739E-13
    array[21] = 9.0536E-14
    array[22] = 5.6098E-15

    return array
  end
end
