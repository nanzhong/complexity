module Complexity

  class Result

    attr_reader :start, :stop, :step

    def self.load(file_path)
      data = {}
      start = nil
      stop = nil
      step = nil
      File.open(file_path) do |f|
        f.each do |line|
          run = {}
          n, run[:min], run[:max], run[:avg] = line.strip.split(",").collect{|d|d.to_f}
          data[n] = run
          step = n - start if step.nil? && !start.nil?
          start = n if start.nil?
          stop = n
        end
      end

      Result.new(start, stop, step, data)
    end

    def initialize(start, stop, step, data)
      @step = step
      @start = start
      @stop = stop
      @data = data
    end

    def test
      # check for exponential
      ratios = []
      (@start..(@stop-@step)).step(@step) do |n|
        ratios << @data[n+@step][:avg] / @data[n][:avg]
      end

      ratios_avg = ratios.inject(:+).to_f / ratios.count
      ratios_std = Math.sqrt(ratios.collect { |i| (i - ratios_avg)**2 }.inject(:+).to_f / ratios.count)
      puts "ratios avg: #{ratios_avg}"
      puts "ratios std: #{ratios_std}"
      if (ratios_std / ratios_avg) < 0.1
        puts "possibly exponential"
      else
        puts "not exponential"
      end

      # check for logarithmic

      # check for polynomial
    end

    def to_s
      @data.collect do |n, run|
        "#{n}:\t#{run[:avg]} (#{run[:min]}-#{run[:max]})"
      end.join("\n")
    end

    def save(file_path)
      File.open(file_path, "w") do |f|
        @data.each do |n, run|
          f.puts "#{n},#{run[:min]},#{run[:max]},#{run[:avg]}"
        end
      end
    end

  end

end
