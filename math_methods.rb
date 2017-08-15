def factorial(n)
	n == 0 ? 1 : n * factorial(n-1) 
end

puts "5! is #{factorial(5)}"
puts "1! is #{factorial(1)}"
puts "0! is #{factorial(0)}"