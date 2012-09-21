require 'benchmark'
require 'parallel'
require_relative 'result'

module Complexity

  class Analyzer

    attr_accessor :bin, :options, :input

    def initialize(bin_path, options = {})
#      raise "Not executable: #{bin_path}" unless File.executable?(bin_path)

      @bin = bin_path
      @options = { :time => :real }
      @options.merge!(options)
      @input = ->{ raise "Undefined input generation method" }
    end

    def run(options = {})
      options = { :start => 0,
                  :stop  => 4000,
                  :step  => 100,
                  :runs  => 3 }.merge(options)

      data = {}
      (options[:start]...options[:stop]).step(options[:step]) do |n|
        run_data = { :min => nil,
                     :max => nil,
                     :sum => 0 }

        input = []
        begin
          options[:runs].times do
            input << @input.call(n)
          end
        rescue
          raise "Error generating input for n=#{n}, run=#{run}"
        end

        tms = Parallel.map(input, :in_processes => 4) do |input|
          Benchmark.measure { IO.popen(@bin, 'r+') { |io| io.write input } }
        end

        tms.each do |t|
          time = case @options[:time]
                 when :real then t.real
                 when :sys  then t.stime
                 when :usr  then t.utime
                 else            t.real
                 end

          run_data[:min] = time if run_data[:min].nil? || run_data[:min] > time
          run_data[:max] = time if run_data[:max].nil? || run_data[:max] < time
          run_data[:sum] += time
        end

        puts "#{n}/#{options[:stop]}"
        run_data[:avg] = run_data[:sum].to_f/options[:runs]
        data[n] = run_data
      end

      Result.new(options[:start], options[:stop], options[:step], data)
    end

  end

end
