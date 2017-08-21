#Yahtzee

class Score
	attr_accessor :points, :used, :unused
	def initialize(points=0, used=[], unused=[])
		@points = points
		@used = used
		@unused = unused
	end
end

class Roll
	attr_accessor :dice
	attr_reader :counts

	def initialize(d1=rand(1..6), d2=rand(1..6), d3=rand(1..6), d4=rand(1..6), d5=rand(1..6))
		@dice = [d1, d2, d3, d4, d5]
		update_counts
	end

    def update_counts
    	@counts = [0,0,0,0,0,0,0]
    	(0..4).each { |value| @counts[@dice[value]] += 1 }
    end

    # return an array of indexes of where value is in @dice
    def find_indexes(value)
    	indexes = []
    	(0..4).each { |idx| indexes << idx if @dice[idx] == value }
    	indexes
    end

    def sum_dice
    	@dice.inject(0) { |sum, die| sum += die }
    end

    # re-roll some dice
    #   dice: an array of integers.  expected to contain values in @dice
    def reroll(reroll_values)
    	raise "dice parameter has too many values" if reroll_values.size > 5
    	# identify the indexes to replace
    	indexes_to_replace = []
    	reroll_values.each { |value|
    		indexes_found = find_indexes(value)
	    	raise "value #{value} is not in dice #{@dice}" if indexes_found.empty?
    	    idx = indexes_found - indexes_to_replace # remove indexes already identified to re-roll
    	    if idx.empty?
    	    	raise "No index to add to re-roll list.  dice=#{@dice}, re-roll=#{reroll_values}, value=#{value}, indexes found: #{indexes_found}. indexes identified for re-roll: #{indexes_to_replace}"
    	    end
    	    indexes_to_replace << idx[0]
    	}
    	# re-roll 
    	indexes_to_replace.each { |idx| @dice[idx] = rand(1..6) }
    	update_counts
    end

    # score Ones, Twos, etc
    def score_upper_category(kind)
    	kind * @dice.inject(0) { |count, die| die == kind ? count + 1 : count }
    end

    def score_full_house
    	(@counts.include?(3) && @counts.include?(2)) ? 25 : 0
    end

    def score_small_straight
    	# check each possible starting value for a small straight
    	(1..3).each { |start_value| 
    	  # check if all counts in the sequence are at least 1
          sequence = (start_value..start_value+3)
    	  straight_found = 
    	    sequence.inject(true) { |result, value| result &&= @counts[value] > 0 } 
    	  return 30 if straight_found
    	}
    	return 0
    end

    def score_large_straight
    	# check each possible starting value for a large straight
    	(1..2).each { |start_value| 
    	  # check if all counts in the sequence are at least 1
          sequence = (start_value..start_value+4)
    	  straight_found = 
    	    sequence.inject(true) { |result, value| result &&= @counts[value] > 0 } 
    	  return 40 if straight_found
    	}
    	return 0
    end

    def score_three_of_a_kind
    	(@counts.include?(3) || counts.include?(4) || counts.include?(5)) ? sum_dice : 0
    end

    def score_four_of_a_kind
    	(counts.include?(4) || counts.include?(5)) ? sum_dice : 0
    end

    def score_yahtzee
    	(counts.include?(5)) ? 50 : 0
    end

    def score_chance
    	sum_dice
    end

end

