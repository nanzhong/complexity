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

=begin
result = Complexity::Result.load("bubble_sort.data")
result.test
=end

=begin
a = Complexity::Analyzer.new('~/src/complexity/exponential.rb')
a.input = ->(s){s}
result = a.run
result.save("exponential.data")
result = Complexity::Result.load("exponential.data")
result.graph('exponential.png')
=end

a = Complexity::Analyzer.new('~/src/complexity/merge_sort.rb')
a.input = ->(s){(0..s).to_a.sample(s)}
result = a.run
result.save("merge_sort.data")
result = Complexity::Result.load("merge_sort.data")
result.graph('merge_sort.png')
