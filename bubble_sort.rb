#!/usr/bin/env ruby
data = STDIN.readline.strip.split(/\s+/).collect {|i| i.to_i}

loop do
  swp = false
  (0...(data.length-1)).each do |i|
    if data[i] > data[i+1]
      data[i], data[i+1] = data[i+1], data[i]
      swp = true
    end
  end

  break unless swp
end
