require './data_for_ANS_5_1_1973.rb'
require './run_init.rb'

class RunAns1973 < RunInit
  def run(ts = @ts, t0 = @t0, power = @power, option = @option)
    read_data = DataForANS_5_1_1973.new
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

      case option
      when 1
        printf("ts =  %3d years P/P0 %.12f\n", sec2day(ts_to_f) / 365, p_p0_tatal)
      when 0
        printf("%3d %11d %.12f\n", sec2day(ts_to_f) / 365, ts_to_f, p_p0_tatal)
      when 2
        printf("ts = %.1f sec, t0 = %.1f sec, P/P0 = %.8f , power = %.5f MW\n",
               ts_to_f, t0_to_f, p_p0_tatal, p_p0_tatal * power_to_f)
      when 3
        f = File.new("./#{@file_name}", 'a+')
        f.printf("%11d %.12f\n", ts_to_f, p_p0_tatal)
        f.close
      end
    end
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
    p_p0 = p_p0_source[:ts] - p_p0_source[:ts_add_t0]
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
