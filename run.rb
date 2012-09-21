require_relative 'lib/analyzer'

=begin
a = Complexity::Analyzer.new('~/src/complexity/sleep.rb')
a.input = ->(s){s}
result = a.run
puts result.to_s
=end

=begin
a = Complexity::Analyzer.new('~/src/complexity/bubble_sort.rb')
a.input = ->(s){(0..s).to_a.sample(s)}
result = a.run
result.save("bubble_sort.data")
=end

result = Complexity::Result.load("bubble_sort.data")
result.test
