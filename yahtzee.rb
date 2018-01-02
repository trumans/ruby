#Yahtzee

module Categories
    UPPER = [ :ones, :twos, :threes, :fours, :fives, :sixes ]
    LOWER = [ 
        :three_of_a_kind, :four_of_a_kind, :full_house, 
        :small_straight, :large_straight, :yahtzee, :chance 
    ]
end

class CategoryValue
    attr_accessor :category, :value
    def initialize(category, value)
        if  !Categories::UPPER.include?(category) && 
            !Categories::LOWER.include?(category)
            raise "'#{category}' is an invalid category"
        end
        @category = category
        @value = value
    end
end

class RankedCategories
    attr_accessor :list
    def initialize
        @list = []
    end

    def add(category, value)
        @list << CategoryValue.new(category, value)
    end

    def sort_ascending
        @list.sort! { |x,y| x.value <=> y.value }
    end

    def sort_descending
        @list.sort! { |x,y| y.value <=> x.value }
    end

    def to_a
        @list.map { |c| [c.category, c.value] }
    end

end


class ScoreSheet
	attr_accessor :points, :scorers
	def initialize()
        @points = {}
        Categories::UPPER.each { |c| @points[c] = nil}
        Categories::LOWER.each { |c| @points[c] = nil}
	end

    # Find the best score based on open categories
    #   roll: a dice roll, object type Roll
    def find_best_score(roll)
        debug = false
        scores = {}
        best_score = nil
        puts("roll is #{roll.dice}") if debug
        @points.each { |key, value| 
            if value == nil
                v = roll.score_category(key)
                puts("key #{key} scores #{v}") if debug
                scores[key] = v 
                best_score = [key, v] if (best_score == nil) or (v > best_score[1])
            end
        }
        puts("best score is #{best_score}") if debug
        best_score
    end

    # Return open categories ranked by score for a roll  
    #   parameter roll [object Roll]: the roll to be scored against open categories.
    #   return: object RankedCategory, sorted by scored in descending order
    def rank_open_categories(roll)
        debug = false
        open_cats = RankedCategories.new
        puts("roll is #{roll.dice}") if debug
        @points.each { |cat, value| 
            if value == nil
                score = roll.score_category(cat)
                puts("category #{cat} scores #{score}") if debug
                open_cats.add(cat, score) 
            end
        }
        open_cats.sort_descending
        puts("ranked categories (2) are #{open_cats}") if debug
        open_cats
    end

    def print_score_sheet
        def val(v)
            if v.nil?
                " -"
            elsif v<10
                " #{v}"
            else
                "#{v}"
            end
        end
        puts "*************"
        puts "Upper section"
        puts "Ones:   #{val(@points[:ones])}"
        puts "Twos:   #{val(@points[:twos])}"
        puts "Threes: #{val(@points[:threes])}"
        puts "Fours:  #{val(@points[:fours])}"
        puts "Fives:  #{val(@points[:fives])}"
        puts "Sixes:  #{val(@points[:sixes])}"
        upper_total = Categories::UPPER.inject(0) { |t, c|
            t + (@points[c].nil? ? 0 : @points[c])
        }
        puts "----------"
        puts "Total:  #{upper_total}"
        upper_bonus = (upper_total >= 63 ? 35 : 0)
        puts "Bonus:  #{upper_bonus}"
        puts
        puts "Lower section"
        puts "3-of-a-kind:    #{val(@points[:three_of_a_kind])}"
        puts "4-of-a-kind:    #{val(@points[:four_of_a_kind])}"
        puts "Full house:     #{val(@points[:full_house])}"
        puts "Small straight: #{val(@points[:small_straight])}"
        puts "Large straight: #{val(@points[:large_straight])}"
        puts "Yahtzee:        #{val(@points[:yahtzee])}"
        puts "Chance:         #{val(@points[:chance])}"
        lower_total = Categories::LOWER.inject(0) { |t, c|
            t + (@points[c] == nil ? 0 : @points[c])
        }
        puts "------------------"
        puts "Total:          #{lower_total}"

        grand_total = upper_total+upper_bonus+lower_total
        puts "=================="
        puts "Grand Total:   #{grand_total}"

        puts "******************"
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
        @distribution = " xxxxxx"
    	(0..4).each do |value| 
            @counts[@dice[value]] += 1
            @distribution[value] = value.to_s
        end
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
    #   values [array]: an array of dice values.  expected to contain values in @dice
    def reroll_values(values)
    	raise "dice parameter has too many values" if values.size > 5
    	# identify the positions to replace
    	positions_to_replace = []
    	values.each { |value|
    		positions_found = find_positions_with_value(value)
	    	raise "value #{value} is not in dice #{@dice}" if positions_found.empty?
    	    pos = positions_found - positions_to_replace # remove positions already identified to re-roll
    	    if pos.empty?
    	    	raise "No dice to add to re-roll list.  dice=#{@dice}, re-roll=#{values}, value=#{value}, indexes found: #{indexes_found}. indexes identified for re-roll: #{indexes_to_replace}"
    	    end
    	    positions_to_replace << pos[0] # add one position since values may be in multiple positions.
    	}
    	# re-roll 
    	positions_to_replace.each { |p| set_die(p, rand(1..6)) }
    	update_counts
    end

    # re-roll some dice
    #   reroll_positions: an array of dice positions.  expected to contain integers 1-5
    def reroll_positions(positions)
        raise "dice parameter has too many values" if positions.size > 5
        positions.each { |p| 
            raise "invalid dice position '#{p}'. expected integer 1-5" if !(1..5).include?(p)
            set_die(p, rand(1..6)) }
        update_counts
    end


    def print_roll
        (1..5).each { |i| puts "die #{i}: #{get_die(i)}  "}
    end

    def find_best_score(score_sheet)
        debug = false
        scores = {}
        best_score = nil
        puts("roll is #{@dice}") if debug
        score_sheet.points.each { |key, value| 
            if value == nil
                v = score_category(key)
                puts("key #{key} scores #{v}") if debug
                scores[key] = v 
                best_score = [key, v] if (best_score == nil) or (v > best_score[1])
            end
        }
        puts("best score is #{best_score}") if debug
        best_score
    end

    def score_category(category)
        case category
        when :ones
            score_upper_category(1)
        when :twos
            score_upper_category(2)
        when :threes
            score_upper_category(3)
        when :fours
            score_upper_category(4)
        when :fives
            score_upper_category(5)
        when :sixes
            score_upper_category(6)
        when :three_of_a_kind
            score_three_of_a_kind
        when :four_of_a_kind
            score_four_of_a_kind
        when :full_house
            score_full_house
        when :small_straight
            score_small_straight
        when :large_straight
            score_large_straight
        when :yahtzee
            score_yahtzee
        when :chance
            score_chance
        else
            raise "category '#{category}' not recognized"
        end
    end

    # score Ones, Twos, etc
    def score_upper_category(value)
    	value * @dice.inject(0) { |count, die| die == value ? count + 1 : count }
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

    # Calculating proabilities:
    #   frequency of outcomes / total possible outcomes
    #   total possible outcomes is 6 to the power of the dice used 
    #     (e.g. 3 dice has 6 cubed possible outcomes )

    # useful_results [integer]: number of beneficial sequences
    # reroll_count [integer]: number of dice rerolled
    def calculate_probability(useful_results, reroll_count)
       return 100.0 * useful_results / ( 6 ** reroll_count )
    end

    # Calculate probably of three or four-of-a-kind
    #   minimum_count [integer]: 3 or 4 assumed
    #   actual_count [integer]: number of dice not to be rerolled, assumed 0-5
    
    def probability_n_of_a_kind(minimum_count, actual_count)
        debug = false
        gap = [(minimum_count - actual_count), 0].max  # number of dice needed for minimum
        puts "minimum count: #{minimum_count}, actual count: #{actual_count}, gap: #{gap}" if debug
        if gap == 0 
            useful_results = 1
            reroll_count = 0
        else
            case [minimum_count, gap]
            when [3, 1] # need 1 of 3 to match
                # sequences with 1 of 3 dice: --*, -*-, *--
                # sequences with 2 of 3 dice: -**, *-*, **-
                # sequences with 3 of 3 dice: *** 
                useful_results = (3*5*5)+(3*5)+1 
            when [3, 2] # need 2 of 4 to match
                # sequences with 2 of 4 dice: --**, -*-*, -**-, *--*, *-*-, **--
                # sequences with 3 of 4 dice: -***, *-**, ***-
                # sequences with 4 of 4 dice: ****
                useful_results = (6*5*5)+(4*5)+1
            when [3, 3] # need 3 of 5 to match
                # sequences with 3 of 5: --***, -**-*, -***-, *--**, *-*-*, *-**-, **--*, **-*-, ***--
                # sequences with 4 of 5: -****, *-***, ***-*, ****-
                # sequences with 5 of 5: ***** 
                useful_results = (9*5*5)+(4*5)+1
            when [4, 1] # need 1 of 2 to match
                # sequences with 1 of 2 dice: -*, *-
                # sequences with 2 of 2 dice: **
                useful_results = (2*5)+1  
            when [4, 2] # need 2 of 3 to match
                # sequences with 2 of 3: -**, *-*, **-
                # sequences with 3 of 3: ***
                useful_results = (4*5)+1
            when [4, 3] # need 3 of 4 dice to match
                # sequences with 3 of 4 dice: -***, *-**, ***-
                # sequences with 4 of 4 dice: ****
                useful_results = (3*5)+1
            when [4, 4] # need 4 of 5 dice to match
                # sequences with 4 of 5: -****, *-***, ***-*, ****-
                # sequences with 5 of 5: ***** 
                useful_results = (4*5)+1  
            else
                raise "pair [#{minimum_count}, #{gap}] not expected"
            end
            reroll_count = 5 - actual_count
        end
        puts "useful results: #{useful_results}, reroll count: #{reroll_count}" if debug
        p = calculate_probability(useful_results, reroll_count)
        return p
    end

    def probability_upper_category(value)
        debug = true
        count = @dice.inject(0) { |c, die| die == value ? c + 1 : c }

        p = probability_n_of_a_kind(3, count)
 
        puts("minimum for #{value} probability for #{dice} is #{'%.2f' % p}% or 1 in #{'%d' % (100/p)}") if debug
        return p
    end

    def probability_three_of_a_kind
        debug = true
#        high_count = 5.downto(0).select { |i| @counts.index(i)  }[0]

        p = probability_n_of_a_kind(3, @counts.max)
 
        puts("three-of-a-kind probability for #{dice} is #{'%.2f' % p}% or 1 in #{'%d' % (100/p)}") if debug
        return p
    end

    def probability_four_of_a_kind
        debug = true
#        high_count = 5.downto(0).select { |i| @counts.index(i)  }[0]

        p = probability_n_of_a_kind(4, @counts.max)
 
        puts("four-of-a-kind probability for #{dice} is #{'%.2f' % p}% or 1 in #{'%d' % (100/p)}") if debug
        return p
    end

    def probability_full_house
        debug = true
        if score_full_house > 0
            useful_results = 1
            reroll_count = 0
        elsif counts.include?(5)
            # have a triplet.  need a pair other than the triplet
            useful_results = 5
            reroll_count = 2
        elsif counts.include?(4) || counts.include?(3)
            # have a triplet.  need to match a single 
            useful_results = 1
            reroll_count = 1
        elsif counts.include?(2) 
            # have two pairs.
            x = counts.select { |c| c == 2 }
            if x.size == 2
                # have two pairs.  need a single to match either
                useful_results = 2
                reroll_count = 1
            else
                # have a pair and three singles.  
                # need a triplet or match to make triplet + another pair
                useful_results = 1 + 1
                reroll_count = 2
            end
        else 
            # have only singles.  need a pair to match a triplet + 
            #                     match another single for a pair
            useful_results = 6
            reroll_count = 3
        end

        p = calculate_probability(useful_results, reroll_count)
        puts("full house probability for #{dice} is #{'%.2f' % p}% or 1 in #{'%d' % (100/p)}") if debug
        return p
    end

    def find_sequences
        current = []
        found = []
        (1..6).each { |i| 
            if @counts[i] > 0 # add to sequence
                current << i
            elsif !current.empty? # a sequence ended
                found << current
                current = []
            end
        }
        found << current if !current.empty?
        return found
    end

    def find_sequence_gaps
        current = []
        found = []
        (1..6).each { |i| 
            if @counts[i] == 0 # add to sequence gap
                current << i
            elsif !current.empty? # a gap ended
                found << current
                current = []
            end
        }
        found << current if !current.empty?
        return found
    end

    def count_dice_in_sequence(start_value, end_value)
        (start_value..end_value).inject(0) { |t, v| @counts[v]>0 ? t += 1 : t }
    end

    def probability_small_straight

        # return true if dice has sequence 1,2,3 or 4,5,6
        def missing_one_at_one_end
            [1,4].each { |i|
                return true if @counts[i]>0 && @counts[i+1]>0 && @counts[i+2]>0
            }
            return false
        end

        # return true if dice has sequence 1,2,3 or 4,5,6
        def missing_one_at_either_end
            [2,3].each { |i|
                return true if @counts[i]>0 && @counts[i+1]>0 && @counts[i+2]>0
            }
            return false
        end

        # return true if potential straight is missing one in the middle
        def missing_one_in_middle
            regex1 = /[1-6]x[1-6][1-6]/  # example: " x23x5x"
            regex2 = /[1-6][1-6]x[1-6]/  # example: " x2x45x"
            return ( @distribution.match(regex1) || @distribution.match(regex2) )
=begin
            [1,2,3].each { |i| 
                return true if @counts[i]>0 && @counts[i+1]==0 && counts[i+2]>0 && counts[i+3]>0
                return true if @counts[i]>0 && @counts[i+1]>0 && counts[i+2]==0 && counts[i+3]>0
            }
            return false
=end
        end

        # return true if potential straight with two missing
        def missing_sequence_of_two
            [1,2,3].each {|i|
                return true if count_dice_in_sequence(i, i+3) == 2
           }
           return false
        end

        def missing_two_non_sequential_in_middle
            regex1 = /x[1-6]x[1-6]/  # example: " x2x4xx", 
            regex2 = /[1-6]x[1-6]x/  # example: " 1x3xxx"
            return ( @distribution.match(regex1) || @distribution.match(regex2) )            
        end

        # return true if no sequences in potential straight
        def has_no_sequences
            [1,2,3].each {|i|
                return true if count_dice_in_sequence(i, i+3) == 1
           }
           return false
        end

        debug = true
        if score_small_straight > 0
            useful_results = 1
            reroll_count = 0
        else
            sequences = find_sequences
            gaps = find_sequence_gaps
            puts "sequences: #{sequences}" if debug
            puts "sequence gaps: #{gaps}" if debug
            if missing_one_at_one_end
                puts "missing one at one end" if debug
                # e.g. sequence 1,2,3: useful results = 4*, *4, 44 (*=1,2,3,5,6)
                useful_results = (2*5)+1
                reroll_count = 2
            elsif missing_one_at_either_end
                puts "missing one at either end" if debug
                #  e.g. sequence 2,3,4: useful results = 1*, 5*, *1, *5, 15, 51 (*=2,3,4, or 6)
                useful_results = (4*4)+2
                reroll_count = 2
            elsif missing_one_in_middle
                puts "missing one in middle" if debug
                # ex 1,2,4: 3*, *3, 33 (where *=1,2,4,5,or 6)
                useful_results = (2*5) + 1
                reroll_count = 2
            elsif missing_sequence_of_two
                puts "missing sequence of two" if debug
                # example: sequence 1,2 with gap 3,4.
                #   useful results:
                #   (34*, 43*, 3*4, 4*3, *34, *43) +  [where *=1,2,5,6]
                #   (343, 344, 433, 434, 334, 443)
                useful_results = (6*4) + 6
                reroll_count = 3


                # NEXT: 
                # small straight probability for [2, 3, 2, 2, 6] is 13.89% or 1 in 7
                # should this probability be better? consider 1,4 or 4,5 

                # example: sequence 2,3 with gap 1,4 or 4,5.
                #   useful results:
                #   (14*, 41*, 1*4, 4*1, *14, *41) +  [where *=2,3,5,6]
                #   (141, 144, 411, 414, 114, 441) +
                #   (45*, 54*, 4*5, 5*4, *45, *54) +  [where *=1,2,3,6]
                #   (454, 455, 544, 545, 445, 554)                 
                #useful_results = ((6*4) + 6) * 2
                #reroll_count = 3
                
            elsif missing_two_non_sequential
                puts "missing two that are non-sequential" if debug
                # example: sequence 1,3 with gap 2,4
                #   useful results:
                #   (24*, 42*, 2*4, 4*2, *24, *42) +  [where *=1,3,5,6]
                #   (242, 244, 422, 424, 224, 442)

                useful_results = (6*4) + 6
                reroll_count = 3
            elsif has_no_sequences
                # potential sequences have 3 values missing
                # keep 1, need 234
                # keep 2, need 345, 134
                # keep 3, need 124, 245, 456
                # keep 4, need 123, 235, 356
                # keep 5, need 234, 346
                # keep 6, need 345
                if @counts[3]>0 || @counts[4]>0
                    useful_sequences = 3
                elsif @counts[2]>0 || @counts[5]>0
                    useful_sequences = 2
                elsif @counts[1]>0 || @counts[6]>0
                    useful_sequences = 1
                else
                    raise "no conditions true in if-then-else for counts"
                end

                # ex: solo 6
                # useful results:
                # ( ( 345,  354,  435,  453,  534,  543) x reroll_count x unneeded_values ) +
                # ( (3345, 3354, 3435, 3453, 3534, 3543) + 
                #   (4345, 4354, 4435, 4453, 4534, 4543) +
                #   (5345, 5354, 5435, 5453, 5534, 5543) +

                #   (            4335, 4353, 5334, 5343) +
                #   (3445, 3454,             5434, 5443) +
                #   (3545, 3554, 4535, 4553            ) +

                #   (                  4533,       5433) +
                #   (      3544,             5344      ) +
                #   (3455,       4355                  )

                useful_results = Permutations.useful_rolls([5,4,3], 4).count #((6*4*2)+(18+12+6))*useful_sequences
                reroll_count = 4
            else
                raise "no sequence identifed from #{sequences}"
            end
        end

        p = calculate_probability(useful_results, reroll_count)
        puts("small straight probability for #{dice} is #{'%.2f' % p}% or 1 in #{'%d' % (100/p)}") if debug
        return p 
    end

    def probability_yahtzee
        # frequency of outcome: one value of highest count
        debug = true
        if score_yahtzee > 0
            reroll_count = 0
        else
            reroll_count = 5 - counts.max
        end

        p = calculate_probability(1, reroll_count)
        puts("yahtzee probability for #{dice} is #{'%.2f' % p}% or 1 in #{'%d' % (100/p)}") if debug
        return p
    end

end

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

