class RunInit
  attr_accessor :ts, :t0, :power

  def initialize(hash_data, option = 0, file_name = 'default.txt')
    @ts = hash_data[:ts]
    @t0 = hash_data[:t0]
    @power = hash_data[:power]
    @option = option
    @file_name = file_name
  end

  # day2sec(day)
  def day2sec(day)
    if day < 86400 * 10
      return day * 24 * 3600.0
    end
  end

  # sec2day(sec)
  def sec2day(sec)
    return sec / 24 / 3600.0
  end
end
