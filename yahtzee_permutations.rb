# Permutation
class Permutations
	# permutations of items in an array
	#   parameter items [Array] - an array of items
	# returns array of arrays where subarrays are a permutation of 'items'
	# Example: array_permuations([1,2,3]) returns
	#   [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]]
	def self.for_array(items)
  		if !items.class == Array
  			raise "parameter 'items' is class '#{items.class}'.  Expected class Array"
		elsif items.length == 1
  			# if one item simply return it
			return items
		elsif items.length == 2
			# if two items then return array of pairs of arrangements
			return [ [items[0], items[1]], [items[1], items[0]] ]
		else
 			ret = []
 			# for each item in the array
 			# create a list of permutations without it
 			# add it to each sub-permutation
			items.each_index do |idx|
  				temp = items.dup 
		  		temp.delete_at(idx)  
  				perms = self.for_array(temp)
 	 			ret += perms.map { |perm| perm.insert(0, items[idx]) }
	  		end 
  			ret 
		end
	end

	# permutations of dice rolls
	#   count [integer]: dice rolled.  value 1-5
	# returns array of arrays where subarrays are a permutation of 'count' dice
	# Example: roll_permutations(2) returns
	#  [[1, 1], [1, 2], [1, 3], [1, 4], [1, 5], [1, 6], 
	#   [2, 1], [2, 2], [2, 3], [2, 4], [2, 5], [2, 6], 
	#   [3, 1], [3, 2], [3, 3], [3, 4], [3, 5], [3, 6], 
	#   [4, 1], [4, 2], [4, 3], [4, 4], [4, 5], [4, 6], 
	#   [5, 1], [5, 2], [5, 3], [5, 4], [5, 5], [5, 6], 
	#   [6, 1], [6, 2], [6, 3], [6, 4], [6, 5], [6, 6]]
	def self.for_dice(dice_count)
		if !(1..5).include?(dice_count)
			raise "dice_count '#{dice_count} must be in range 1-5"
		elsif dice_count == 1
			# if only one die then return an array of arrays with single value 1-6
			return (1..6).map { |d| [d] }
		else
			# add the die values 1-6 to each permutation for next smaller die count 
			return self.for_dice(dice_count-1).inject([]) { |perms, roll| 
				perms += (1..6).map {|d| roll.dup << d}
			}
		end
	end

	# Create a list useful rolls
	#   useful_values [Array]: array of dice values (integers 1-6)
	#   dice_rolled [Integer]: value 1-5
	# return a list of permutations containing useful_values plus additional dice
	#   to fill permutations to the length 'dice_rolled'
	# Example: useful_rolls([3,4], 3)
	#   [[1, 2, 1], [1, 1, 2], [2, 1, 1], 
	#    [1, 2, 2], [2, 1, 2], [2, 2, 1], 
	#    [1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1], 
	#    [1, 2, 4], [1, 4, 2], [2, 1, 4], [2, 4, 1], [4, 1, 2], [4, 2, 1], 
	#    [1, 2, 5], [1, 5, 2], [2, 1, 5], [2, 5, 1], [5, 1, 2], [5, 2, 1], 
	#    [1, 2, 6], [1, 6, 2], [2, 1, 6], [2, 6, 1], [6, 1, 2], [6, 2, 1]]
	def self.useful_rolls(useful_values, dice_rolled)
		extra_dice_count = dice_rolled - useful_values.length  # dice whose values don't matter
		if extra_dice_count < 0 
			raise "dice_rolled '#{dice_rolled}' cannot be fewer than useful_values #{useful_values}"
		elsif extra_dice_count == 0  
			# return permutations of useful values if no extra dice 
			#   (i.e. all dice required for useful values)
			return self.for_array(useful_values)
		else 
			# rolling more dice than required for useful values. 
			extra_dice = self.for_dice(extra_dice_count) 
			ret = []
			extra_dice.each { |extra| ret += self.for_array(useful_values + extra) }
			return ret.uniq
		end
	end

end

p = Permutations.for_array([3,4])
print p, "\n#{p.count} items\n"
puts
p = Permutations.for_array([1,2,3])
print p, "\n#{p.count} items\n"
puts
p = Permutations.for_array([1,2,3,4])
print p, "\n#{p.count} items\n" 
puts
p = Permutations.for_dice(1)
print p, "\n#{p.count} items\n"
puts
p = Permutations.for_dice(2)
print p, "\n#{p.count} items\n"
puts
p = Permutations.for_dice(3)
print p, "\n#{p.count} items\n"
puts
puts
u = Permutations.useful_rolls([1,2], 3)
puts "#{u}"
puts "#{u.size} useful rolls" 
puts
u = Permutations.useful_rolls([6,5], 4)
puts "#{u}"
puts "#{u.size} useful rolls" 
puts