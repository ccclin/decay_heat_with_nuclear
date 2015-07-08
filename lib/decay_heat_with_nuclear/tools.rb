module Tools
  class TextToArray
    attr_accessor :output

    def initialize(filename)
      @output = {}
      ts = []
      t0 = []
      power = []
      f = File.open("#{filename}", 'r')
      f.each_line do |line|
        a, b, c = line.split("\t")
        ts << a.to_f
        t0 << b.to_f
        power << c.to_f
      end
      f.close
      @output = { ts: ts, t0: t0, power: power }
    end
  end
end
