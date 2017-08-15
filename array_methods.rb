class ArrayPlus < Array
	def bubble_sort() 
		for i in 0...self.length-1 do
			for j in i+1...self.length do
				if (self[j] < self[i])
					t = self[j]
					self[j] = self[i]
					self[i] = t
				end
			end
		end
	end

	def binary_search(search_value)
		count = 0 
		top = 0; bottom = self.length-1
		while true do 
			mid = top + ((bottom - top) / 2).ceil
			count += 1
			if self[mid] == search_value
				return mid, count
			elsif top == bottom
				return -1, count
			elsif self[mid] > search_value
				bottom = [mid-1, 0].max
			else
				top = [mid+1, self.length].min
			end
		end
	end

end

myArray = ArrayPlus.new(["apple", "peach", "blueberry", "mango", "pineapple", "persimmon", "mandarin","banana"])
puts "UNSORTED"
puts myArray
myArray.bubble_sort
puts "=======\nSORTED"
puts myArray
r = myArray.binary_search('peach')
puts "index of peach is #{r[0]} after #{r[1]}"
r = myArray.binary_search('apple')
puts "index of apple is #{r[0]} after #{r[1]}"
r = myArray.binary_search('pineapple')
puts "index of pineapple is #{r[0]} after #{r[1]}"
r = myArray.binary_search('aardvark')
puts "index of aardvark is #{r[0]} after #{r[1]}"
r = myArray.binary_search('plum')
puts "index of plum is #{r[0]} after #{r[1]}"
r = myArray.binary_search('yak')
puts "index of yak is #{r[0]} after #{r[1]}"
