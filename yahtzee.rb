#Yahtzee

# Next:
#   Finish find_best_score to return the single best score from values 
#   Create unit tests to verify find_best_score for all categories.
#
#   Create method to update score sheet with a roll
#   Create method to print score sheet.  
#     Calc bonus on upper section
#     Subtotal on upper and lower sections and grand total
#

class ScoreSheet
	attr_accessor :points, :scorers
	def initialize()
        @points = { 
            ones: nil, twos: nil, three: nil, fours: nil, fives: nil, sixes: nil,
            three_of_a_kind: nil, four_of_a_kind: nil, full_house: nil, 
            small_straight: nil, large_straight: nil, yahtzee: nil, chance: nil 
        }
        @scorers = { 
            ones: "score_upper_category(1)", 
            twos: "score_upper_category(2)", 
            three: "score_upper_category(3)", 
            fours: "score_upper_category(4)", 
            fives: "score_upper_category(5)", 
            sixes: "score_upper_category(6)",
            three_of_a_kind: "score_three_of_a_kind", 
            four_of_a_kind: "score_four_of_a_kind", 
            full_house: "score_full_house",
            small_straight: "score_small_straight", 
            large_straight: "score_large_straight",
            yahtzee: "score_yahtzee", 
            chance: "score_chance" 
        }
	end

    # Find the best score based on open categories
    #   roll: a dice roll, object type Roll
    def find_best_score(roll)
        scores = {}
        @points.each { |key, value| 
            if value == nil
                v = (eval "roll."+@scorers[key])
                puts "key #{key} scores #{v}"
                scores[key] = v
            end
        }
        puts "best score for dice #{roll.dice} is #{scores.inspect}"
    end
end

class Roll
	attr_accessor :dice
	attr_reader :counts

	def initialize(d1=rand(1..6), d2=rand(1..6), d3=rand(1..6), d4=rand(1..6), d5=rand(1..6))
		@dice = [d1, d2, d3, d4, d5]
		update_counts
	end

    # return a die's value
    #   position: die position, integer 1-5
    def get_die(position)
        raise "index must be in range 1-5" if not (1..5).include?(position)
        return @dice[position-1]
    end

    # update a die's value
    #   position: die position, integer 1-5
    #   value: integer 1-6
    def set_die(position, value)
        raise "position must be in range 1-5" if not (1..5).include?(position)
        raise "die value must be in range 1-6" if not (1..6).include?(value)
        @dice[position-1] = value
    end

    def update_counts
    	@counts = [0,0,0,0,0,0,0]
    	(0..4).each { |value| @counts[@dice[value]] += 1 }
    end

    # return an array of dice positions (1-5) that equal value in @dice
    #   
    def find_positions_with_value(value)
    	positions = []
    	(1..5).each { |p| positions << p if get_die(p) == value }
    	positions
    end

    def sum_dice
    	@dice.inject(0) { |sum, die| sum += die }
    end

    # re-roll some dice
    #   reroll_values: an array of dice values.  expected to contain values in @dice
    def reroll_values(reroll_values)
    	raise "dice parameter has too many values" if reroll_values.size > 5
    	# identify the positions to replace
    	positions_to_replace = []
    	reroll_values.each { |value|
    		positions_found = find_positions_with_value(value)
	    	raise "value #{value} is not in dice #{@dice}" if positions_found.empty?
    	    pos = positions_found - positions_to_replace # remove positions already identified to re-roll
    	    if pos.empty?
    	    	raise "No dice to add to re-roll list.  dice=#{@dice}, re-roll=#{reroll_values}, value=#{value}, indexes found: #{indexes_found}. indexes identified for re-roll: #{indexes_to_replace}"
    	    end
    	    positions_to_replace << pos[0] # add one position since values may be in multiple positions.
    	}
    	# re-roll 
    	positions_to_replace.each { |p| set_die(p, rand(1..6)) }
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

