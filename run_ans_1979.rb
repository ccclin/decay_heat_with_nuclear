require './data_for_ANS_5_1_1979.rb'
require './run_init.rb'

class RunAns1979 < RunInit
  # attr_accessor :ts, :t0, :power

  # def initialize(hash_data, option = 0)
  #   @ts = hash_data[:ts]
  #   @t0 = hash_data[:t0]
  #   @power = hash_data[:power]
  #   @option = option
  # end

  def run(ts = @ts, t0 = @t0, power = @power, option = @option)
    read_data = DataForANS_5_1_1979.new
    ts.each_index do |i|
      ts_to_f = ts[i].to_f
      t0_to_f = t0[i].to_f
      power_to_f = power[i].to_f

      t0_add_ts = ts_to_f + t0_to_f
      f_ts2t0 = calc_thermal_fission_functions(t0_to_f, ts_to_f, read_data)
      thePd_apostrophe = calc_sum_thermal_fission(f_ts2t0, read_data)
      thePd = calc_total_fission_product(thePd_apostrophe, t0_to_f, ts_to_f, read_data)
      fU239 = calc_thermal_fission_functions_with_U239(t0_to_f, ts_to_f, read_data)
      fNp239 = calc_thermal_fission_functions_with_Np239(t0_to_f, ts_to_f, read_data)
      thePd_all = thePd + ((fU239 + fNp239)/read_data.theQ[:others])
      un = calc_Un(ts_to_f)

      if ts_to_f > 1.0E+03 && ts_to_f < 1.0E+04
        thePd_all_un = thePd_all * 1.03
      elsif ts_to_f >= 1.0E+04
        thePd_all_un = thePd_all * (1.0 + un)
      else
        thePd_all_un = thePd_all * (1 + 3.0E-06 * ts_to_f)
      end

      case option
      when 1
        printf("ts =  %3d years P/P0= %.12f\n", sec2day(ts_to_f) / 365, thePd_all)
      when 0
        printf("%3d %11d %.12f\n", sec2day(ts_to_f) / 365, ts_to_f, thePd_all)
      when 2
        printf( "ts = %.1f sec, t0 = %.1f sec, un = %.8f , P/P0(without un) = %.8f , P/P0(with un) = %.8f , power = %.5f MW\n", 
                ts_to_f, t0_to_f, un, thePd_all, thePd_all_un, thePd_all_un * power_to_f)
      when 3
        f = File.new("./#{@file_name}", 'a+')
        f.printf("%11d %.12f\n", ts_to_f, thePd_all_un)
        f.close
      end
    end
  end

  # Calculate thermal fission functions from ANS-5.1-1979 Table 7~9 include U235, Pu239 and U238.
  # need t0, ts and data with thermal fission(from class DataForANS_5_1_1979)
  # ts: Time after remove (sec)
  # t0: Cumulative reactor operating time (sec)
  #
  # calc_thermal_fission_functions(t0, ts, read_data)
  #
  # return { :U235  => f_U235(ts, t0)
  #          :Pu239 => f_Pu235(ts, t0)
  #          :U238  => f_U238(ts, t0) }
  #
  def calc_thermal_fission_functions(t0, ts, read_data)
    total_times = t0 + ts
    ff = HashWithThermalFission.new
    (0..read_data.theU235_alpha.size-1).each do |i|

      f_U235_ts2tinf        = read_data.theU235_alpha[i] / read_data.theU235_lamda[i] * 
                              Math.exp(-read_data.theU235_lamda[i] * ts) * 
                              (1.0 - Math.exp(-read_data.theU235_lamda[i] * read_data.tinf))

      f_U235_ts_add_t02tinf = read_data.theU235_alpha[i] / read_data.theU235_lamda[i] * 
                              Math.exp(-read_data.theU235_lamda[i] * total_times) *
                              (1.0 - Math.exp(-read_data.theU235_lamda[i] * read_data.tinf))

      ff.thermal_fission[:U235] = ff.thermal_fission[:U235] + f_U235_ts2tinf - f_U235_ts_add_t02tinf

      f_Pu239_ts2tinf         = read_data.thePu239_alpha[i] / read_data.thePu239_lamda[i] * 
                                Math.exp(-read_data.thePu239_lamda[i] * ts) * 
                                (1.0 - Math.exp(-read_data.thePu239_lamda[i] * read_data.tinf))

      f_Pu239_ts_add_t02tinf  = read_data.thePu239_alpha[i] / read_data.thePu239_lamda[i] * 
                                Math.exp(-read_data.thePu239_lamda[i] * total_times) *
                                (1.0 - Math.exp(-read_data.thePu239_lamda[i] * read_data.tinf))

      ff.thermal_fission[:Pu239] = ff.thermal_fission[:Pu239] + f_Pu239_ts2tinf - f_Pu239_ts_add_t02tinf

      f_U238_ts2tinf          = read_data.theU238_alpha[i] / read_data.theU238_lamda[i] * 
                                Math.exp(-read_data.theU238_lamda[i] * ts) * 
                                (1.0 - Math.exp(-read_data.theU238_lamda[i] * read_data.tinf))

      f_U235_ts_add_t02tinf   = read_data.theU238_alpha[i] / read_data.theU238_lamda[i] * 
                                Math.exp(-read_data.theU238_lamda[i] * total_times) *
                                (1.0 - Math.exp(-read_data.theU238_lamda[i] * read_data.tinf))

      ff.thermal_fission[:U238] = ff.thermal_fission[:U238] + f_U238_ts2tinf - f_U235_ts_add_t02tinf
    end
    return ff.thermal_fission
  end

  # Calculate P'di (the uncorrected decay heat power) from ANS-5.1-1979 Eq.6
  # need f_ts2t0, Pi(thePi), Qi(theQ) from class DataForANS_5_1_1979.
  #
  # calc_sum_thermal_fission(f_ts2t0, read_data)
  #
  # return P'd
  #
  def calc_sum_thermal_fission(f_ts2t0, read_data)
    prd = HashWithThermalFission.new
    pd = 0
    prd.thermal_fission.each do |key, value|
      value = value + read_data.thePi[key] * f_ts2t0[key] / read_data.theQ[key]
      pd = pd + value
    end
    return pd
  end

  # Calculate total fission product decay heat power 
  # at t(ts) sec after shutdown from an operating history of T(t0) sec duration. (from ANS-5.1-1979 Eq.1 and 11)
  # need t0, ts and data with thermal fission(from class DataForANS_5_1_1979)
  # ts: Time after remove (sec)
  # t0: Cumulative reactor operating time (sec)
  #
  # calc_total_fission_product(thePd_apostrophe, t0, ts, read_data)
  #
  # return Pd
  #
  def calc_total_fission_product(thePd_apostrophe, t0, ts, read_data)
    g = 1.0 + ((3.24E-06 + 5.23E-10 * ts) * (t0 ** (4.0E-01)) * read_data.phi)
    if g >= 1.1
      g = 1.1
    end
    return thePd_apostrophe * g
  end

  # Calculate U239 fission product decay heat power from ANS-5.1-1979 Eq.14
  # ts: Time after remove (sec)
  # t0: Cumulative reactor operating time (sec)
  #
  # calc_thermal_fission_functions_with_U239(t0, ts, read_data)
  #
  # return fU239
  #
  def calc_thermal_fission_functions_with_U239(t0, ts, read_data)
    return read_data.theEU239 * read_data.theR * (1 - Math.exp(-read_data.lamda1 * t0)) * Math.exp(-read_data.lamda1 * ts)
  end

  # Calculate Np239 fission product decay heat power from ANS-5.1-1979 Eq.15
  # ts: Time after remove (sec)
  # t0: Cumulative reactor operating time (sec)
  #
  # calc_thermal_fission_functions_with_Np239(t0, ts, read_data)
  #
  # return fNp239
  #
  def calc_thermal_fission_functions_with_Np239(t0, ts, read_data)
    return  read_data.theENp239 * read_data.theR * ((read_data.lamda1 / (read_data.lamda1 - read_data.lamda2)) *
            (1 - Math.exp(-read_data.lamda2 * t0)) * Math.exp(-read_data.lamda2 * ts) -
            (read_data.lamda2 / (read_data.lamda1 - read_data.lamda2)) * (1 - Math.exp(-read_data.lamda1 * t0)) * Math.exp(-read_data.lamda1 * ts))
  end

  # Calculate Un is a factor which accounts for the SIL-636 additional terms effect.
  # ts: Time after remove (sec)
  #
  # calc_Un(ts)
  #
  # return un
  #
  def calc_Un(ts)
    un = (6.0E-02 - 3.0E-02) / (1.0E+06 - 1.0E+04) * (ts - 1.0E+04) + 3.0E-02
    if un >= 6.0E-02
      un = 6.0E-02
    end
    return un
  end
end
