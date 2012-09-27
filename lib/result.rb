require 'gruff'

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
      exp_diff = []
      (@start..(@stop-@step)).step(@step) do |n|
        exp_diff << Math.exp(@data[n+@step][:avg]) - Math.exp(@data[n][:avg])
      end

      exp_diff_avg = exp_diff.inject(:+).to_f / exp_diff.count
      exp_diff_std = Math.sqrt(exp_diff.collect { |i| (i - exp_diff_avg)**2 }.inject(:+).to_f / exp_diff.count)
      puts "exp_diff avg: #{exp_diff_avg}"
      puts "exp_diff std: #{exp_diff_std}"
      if (exp_diff_std / exp_diff_avg) < 0.1
        puts "possibly logarithmic"
      else
        puts "not logarithmic"
      end

      # check for polynomial
      degree = 1
      diff = @data.values.collect {|run| run[:avg]}
      loop do
        new_diff = []
        (0..(diff.count - 2)).each do |i|
          new_diff << diff[i+1] - diff[i]
        end
        diff = new_diff

        puts diff.join(" ")

        diff_avg = diff.inject(:+).to_f / diff.count
        diff_std = Math.sqrt(diff.collect { |i| (i - diff_avg)**2 }.inject(:+).to_f / diff.count)

        if diff_avg >= -0.25 && diff_avg <= 0.25
          puts "diff avg close to 0"
          if diff_std / diff_avg < 0.2
            puts "diff std small"
            break
          end
        end

        puts "degree: #{degree}"
        puts "diff avg: #{diff_avg}"
        puts "diff std: #{diff_std}"
        puts "diff std/diff avg: #{diff_std/diff_avg}"
        if (diff_std / diff_avg) < 0.1
          puts "possibly polynomial with degree #{degree}"
        else
          puts "not polynomial with degree #{degree}"
        end

        degree += 1
        sleep 2
      end
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

    def graph(file_path)
      runtime_graph = Gruff::Line.new
      runtime_graph.title = "Runtime Graph"
      runtime_graph.data("avg", @data.values.collect {|run| run[:avg] })
      runtime_graph.data("min", @data.values.collect {|run| run[:min] })
      runtime_graph.data("max", @data.values.collect {|run| run[:max] })
      runtime_graph.marker_count = 5
      runtime_graph.write(file_path)
    end

  end

end
