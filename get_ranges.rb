def get_ranges(array)
	puts "============"
	puts "original array: #{array}"
	# for each size of subranges
	(1..array.size).each do | length |
		last_index = array.size - length
		(0..last_index).each do | start_at |
			puts "#{array[start_at, length]}"
		end
	end
end

get_ranges([1,3,5,8,9])
get_ranges([1])
get_ranges([1,3])
get_ranges([])
