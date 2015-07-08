module MainRun
  class RunInit
    attr_accessor :ts, :t0, :power

    def initialize(hash_data, option = 0, file_name = 'default.txt')
      @ts = hash_data[:ts]
      @t0 = hash_data[:t0]
      @power = hash_data[:power]
      @option = option
      @file_name = file_name
      @output_hash = {
                      ts:             [],
                      p_p0:           [],
                      p_p0_without_k: []
                      }
    end

    def dataout(ts, p_p0, p_p0_without_k = nil)
      @output_hash[:ts] << ts
      @output_hash[:p_p0] << p_p0
      @output_hash[:p_p0_without_k] << p_p0_without_k if p_p0_without_k
    end

    # day2sec(day)
    def day2sec(day)
      if day < 86400 * 10
        day * 24 * 3600.0
      end
    end

    # sec2day(sec)
    def sec2day(sec)
      sec / 24 / 3600.0
    end
  end

  class RunAns1973 < RunInit
    def run(ts = @ts, t0 = @t0, power = @power)
      read_data = ThermalData::DataForANS_5_1_1973.new
      ts.each_index do |i|
        ts_to_f = ts[i].to_f
        t0_to_f = t0[i].to_f
        power_to_f = power[i].to_f

        t0_add_ts   = ts_to_f + t0_to_f

        p_p0_source = calc_thermal_fission_functions(t0_to_f, ts_to_f, read_data)
        p_p0        = calc_sum_thermal_fission(p_p0_source)

        p_p0_U239   = calc_thermal_fission_functions_with_U239(t0_to_f, ts_to_f)
        p_p0_Np239  = calc_thermal_fission_functions_with_Np239(t0_to_f, ts_to_f)

        p_p0_tatal    = p_p0 + p_p0_U239 + p_p0_Np239

        dataout(ts_to_f, p_p0_tatal)
      end
      @output_hash
    end

    private

    # Calculate thermal fission functions from ASB9-2.
    # need t0, ts and data with thermal fission(from class DataForASB_9_2)
    # ts: Time after remove (sec)
    # t0: Cumulative reactor operating time (sec)
    #
    # calc_thermal_fission_functions(t0, ts, read_data)
    #
    # return { :ts          => P/P0(t_inf, ts)
    #          :ts_add_t0   => P/P0(t_inf, ts + t0) }
    #
    def calc_thermal_fission_functions(t0, ts, read_data)
      total_times = t0 + ts
      ff = { ts: 0.0, ts_add_t0: 0.0 }

      (0..read_data.theAn.size - 1).each do |i|
        p_p0_tinf2ts        = (1.0 / 200.0) * read_data.theAn[i] * Math.exp(-read_data.thean[i] * ts)

        p_p0_tinf2ts_add_t0 = (1.0 / 200.0) * read_data.theAn[i] * Math.exp(-read_data.thean[i] * total_times)

        ff[:ts] = ff[:ts] + p_p0_tinf2ts
        ff[:ts_add_t0] = ff[:ts_add_t0] + p_p0_tinf2ts_add_t0
      end
      ff
    end

    def calc_sum_thermal_fission(p_p0_source)
      p_p0_source[:ts] - p_p0_source[:ts_add_t0]
    end

    def calc_thermal_fission_functions_with_U239(t0, ts)
      0.00228 * 0.7 * (1 - Math.exp(-0.000491 * t0)) * Math.exp(-0.000491 * ts)
    end

    def calc_thermal_fission_functions_with_Np239(t0, ts)
      a1 = 4.91E-4
      a2 = 3.41E-6
      0.00217 * 0.7 * ((a1 / (a1 + a2)) * (1 - Math.exp(-a2 * t0)) * Math.exp(-a2 * ts) - (a2 / (a1 + a2)) * (1 - Math.exp(-a1 * t0)) * Math.exp(-a1 * ts))
    end
  end

  class RunAns1979 < RunInit
    def run(ts = @ts, t0 = @t0, power = @power)
      read_data = ThermalData::DataForANS_5_1_1979.new
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

        dataout(ts_to_f, thePd_all_un)
      end
      @output_hash
    end

    private

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
      ff = ThermalData::HashWithThermalFission.new
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
      ff.thermal_fission
    end

    # Calculate P'di (the uncorrected decay heat power) from ANS-5.1-1979 Eq.6
    # need f_ts2t0, Pi(thePi), Qi(theQ) from class DataForANS_5_1_1979.
    #
    # calc_sum_thermal_fission(f_ts2t0, read_data)
    #
    # return P'd
    #
    def calc_sum_thermal_fission(f_ts2t0, read_data)
      prd = ThermalData::HashWithThermalFission.new
      pd = 0
      prd.thermal_fission.each do |key, value|
        value = value + read_data.thePi[key] * f_ts2t0[key] / read_data.theQ[key]
        pd += value
      end
      pd
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
      thePd_apostrophe * g
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
      read_data.theEU239 * read_data.theR * (1 - Math.exp(-read_data.lamda1 * t0)) * Math.exp(-read_data.lamda1 * ts)
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
      read_data.theENp239 * read_data.theR * ((read_data.lamda1 / (read_data.lamda1 - read_data.lamda2)) *
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
      un
    end
  end

  class RunASB9_2 < RunInit
    def run(ts = @ts, t0 = @t0, power = @power)
      read_data = ThermalData::DataForASB_9_2.new
      ts.each_index do |i|
        ts_to_f = ts[i].to_f
        t0_to_f = t0[i].to_f
        power_to_f = power[i].to_f

        t0_add_ts   = ts_to_f + t0_to_f

        p_p0_source = calc_thermal_fission_functions(t0_to_f, ts_to_f, read_data)
        p_p0        = calc_sum_thermal_fission(p_p0_source, ts_to_f)

        p_p0_U239   = calc_thermal_fission_functions_with_U239(t0_to_f, ts_to_f)
        p_p0_Np239  = calc_thermal_fission_functions_with_Np239(t0_to_f, ts_to_f)

        p_p0_tatal = { with_k: 0, without_k: 0 }
        p_p0_tatal[:with_k]    = p_p0[:with_k] + p_p0_U239 + p_p0_Np239
        p_p0_tatal[:without_k] = p_p0[:without_k] + p_p0_U239 + p_p0_Np239

        dataout(ts_to_f, p_p0_tatal[:with_k], p_p0_tatal[:without_k])
      end
      @output_hash
    end

    private

    # Calculate thermal fission functions from ASB9-2.
    # need t0, ts and data with thermal fission(from class DataForASB_9_2)
    # ts: Time after remove (sec)
    # t0: Cumulative reactor operating time (sec)
    #
    # calc_thermal_fission_functions(t0, ts, read_data)
    #
    # return { :P/P0(t_inf, ts)    => value
    #          :P/P0(t_inf, ts+t0) => f_Pu235(ts, t0) }
    #
    def calc_thermal_fission_functions(t0, ts, read_data)
      total_times = t0 + ts
      ff = { ts: 0.0, ts_add_t0: 0.0 }

      (0..read_data.theAn.size - 1).each do |i|
        p_p0_tinf2ts        = (1.0 / 200.0) * read_data.theAn[i] * Math.exp(-read_data.thean[i] * ts)

        p_p0_tinf2ts_add_t0 = (1.0 / 200.0) * read_data.theAn[i] * Math.exp(-read_data.thean[i] * total_times)

        ff[:ts] = ff[:ts] + p_p0_tinf2ts
        ff[:ts_add_t0] = ff[:ts_add_t0] + p_p0_tinf2ts_add_t0
      end
      ff
    end

    def calc_sum_thermal_fission(p_p0_source, ts)
      p_p0 = { with_k: 0.0, without_k: 0.0 }
      if ts >= 0 && ts < 1.0E+03
        k1 = 0.2
        k2 = 0.2
      elsif ts >= 1.0E+03 && ts <= 1.0E+07
        k1 = 0.1
        k2 = 0.1
      else
        k1 = 0.1
        k2 = 0.0
      end
      p_p0[:with_k] = p_p0[:with_k] + ((1 + k1) * p_p0_source[:ts]) - p_p0_source[:ts_add_t0]
      p_p0[:without_k] = p_p0[:without_k] + ((1 + k2) * p_p0_source[:ts]) - p_p0_source[:ts_add_t0]
      p_p0
    end

    def calc_thermal_fission_functions_with_U239(t0, ts)
      0.00228 * 0.7 * (1 - Math.exp(-0.000491 * t0)) * Math.exp(-0.000491 * ts)
    end

    def calc_thermal_fission_functions_with_Np239(t0, ts)
      a1 = 4.91E-4
      a2 = 3.41E-6
      0.00217 * 0.7 * ((a1 / (a1 + a2)) * (1 - Math.exp(-a2 * t0)) * Math.exp(-a2 * ts) - (a2 / (a1 + a2)) * (1 - Math.exp(-a1 * t0)) * Math.exp(-a1 * ts))
    end
  end
end
