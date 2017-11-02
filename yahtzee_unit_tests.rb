#Yahtzee

require_relative "yahtzee"
require "test/unit"

class TestYahtzee < Test::Unit::TestCase
	def test_scoring
		d = Roll.new(1,2,3,2,6)
		assert_equal([0,1,2,1,0,0,1], d.counts)

		assert_equal(1, d.score_upper_category(1))
		assert_equal(4, d.score_upper_category(2))
		assert_equal(3, d.score_upper_category(3))
		assert_equal(0, d.score_upper_category(4))
		assert_equal(0, d.score_upper_category(5))
		assert_equal(6, d.score_upper_category(6))

		assert_equal(0, d.score_three_of_a_kind)
		assert_equal(0, d.score_four_of_a_kind)
		assert_equal(0, d.score_full_house) 
		assert_equal(0, d.score_small_straight)
		assert_equal(0, d.score_large_straight)
		assert_equal(0, d.score_yahtzee)

		assert_equal(14, d.score_chance)


		d = Roll.new(4,5,4,5,6)
		assert_equal([0,0,0,0,2,2,1], d.counts)

		assert_equal(0, d.score_upper_category(1))
		assert_equal(0, d.score_upper_category(2))
		assert_equal(0, d.score_upper_category(3))
		assert_equal(8, d.score_upper_category(4))
		assert_equal(10, d.score_upper_category(5))
		assert_equal(6, d.score_upper_category(6))

		assert_equal(0, d.score_three_of_a_kind)
		assert_equal(0, d.score_four_of_a_kind)
		assert_equal(0, d.score_full_house) 
		assert_equal(0, d.score_small_straight)
		assert_equal(0, d.score_large_straight)
		assert_equal(0, d.score_yahtzee)

		assert_equal(24, d.score_chance)

		# verify lower combinations are identified.
		# three of a kind
		d = Roll.new(4,3,3,5,3)
		assert_equal(18, d.score_three_of_a_kind)
		d = Roll.new(5,5,2,5,5)
		assert_equal(22, d.score_three_of_a_kind)
		d = Roll.new(2,2,2,2,2)
		assert_equal(10, d.score_three_of_a_kind)
		# four of a kind
		d = Roll.new(4,3,3,3,3)
		assert_equal(16, d.score_four_of_a_kind)
		d = Roll.new(2,2,2,2,2)
		assert_equal(10, d.score_four_of_a_kind)
		# full house
		d = Roll.new(1,1,3,3,1)
		assert_equal(25, d.score_full_house)
		# small straights
		d = Roll.new(4,3,2,4,1)
		assert_equal(30, d.score_small_straight)
		d = Roll.new(4,3,6,1,5)
		assert_equal(30, d.score_small_straight)
		d = Roll.new(5,3,6,2,4)
		assert_equal(30, d.score_small_straight)
		# large straights
		d = Roll.new(4,3,2,5,6)
		assert_equal(40, d.score_large_straight)
		d = Roll.new(4,3,2,1,5)
		assert_equal(40, d.score_large_straight)
		# Yahtzee
		d = Roll.new(3,3,3,3,3)
		assert_equal(50, d.score_yahtzee)
	end

	def test_display_random_roll
		a = Roll.new
		puts "Random roll: #{a.dice}"
		puts "Counts: #{a.counts}"
		puts ""
		puts "Ones score: #{a.score_upper_category(1)}"
		puts "Twos score: #{a.score_upper_category(2)}"
		puts "Threes score: #{a.score_upper_category(3)}"
		puts "Fours score: #{a.score_upper_category(4)}"
		puts "Fives score: #{a.score_upper_category(5)}"
		puts "Sixes score: #{a.score_upper_category(6)}"
		puts ""
		puts "Full house: #{a.score_full_house}"
		puts "Small straight: #{a.score_small_straight}"
		puts "Large straight: #{a.score_large_straight}"
		puts "Three of a kind: #{a.score_three_of_a_kind}"
		puts "Four of a kind: #{a.score_four_of_a_kind}"
		puts "Yahtzee: #{a.score_yahtzee}"
		puts "Chance: #{a.score_chance}"
	end

	# Execute each reroll test individually.  
	# Retry 4 times due to re-roll legitimately returning same value 
	def test_reroll
		["execute_reroll_1", 
		 "execute_reroll_2", 
		 "execute_reroll_3"].each { |fcn|
			begin
				eval fcn
			rescue
				begin
					puts "#{fcn} retry 1"
					eval fcn
				rescue
					begin
						puts "#{fcn} retry 2"
						eval fcn
					rescue
						begin
							puts "#{fcn} retry 3"
							eval fcn 
						rescue
							puts "#{fcn} retry 4"
							eval fcn
						end
					end
				end
			end
		}
	end

	# Reroll tests:
	#   Roll.new(...) - set the dice roll to known values
	#   d.reroll([...]) - reroll(change) die/dice with certain values
	#   assert_equal(...) - verify dice not specified in reroll are not changed
	#   assert_not_equal(...) - verify the select dice changed, 
	#     although there's a 1 in 6 change the rerolled returned the same value
	@@reroll_msg = "Re-run test as re-roll may have returned same value"
	def execute_reroll_1
		d = Roll.new(4,3,2,1,5)
		assert_equal([0,1,1,1,1,1,0], d.counts)
		d.reroll_values([2]) 
		assert_equal([4,3], d.dice[0..1])
		assert_not_equal(2, d.dice[2], @@reroll_msg)
		assert_equal([1,5], d.dice[3..4])
		assert_not_equal([0,1,1,1,1,1,0], d.counts)
	end

	def execute_reroll_2
		d = Roll.new(4,2,4,1,4)
		assert_equal([0,1,1,0,3,0,0], d.counts)
		d.reroll_values([4,4])
		assert_not_equal(4, d.dice[0], @@reroll_msg)
		assert_equal(2, d.dice[1])
		assert_not_equal(4, d.dice[2], @@reroll_msg)
		assert_equal([1,4], d.dice[3..4])
		assert_not_equal([0,1,1,0,3,0,0], d.counts)
	end

	def execute_reroll_3
		d = Roll.new(4,2,4,1,3)
		assert_equal([0,1,1,1,2,0,0], d.counts)
		d.reroll_values([1,3])
		assert_equal([4,2,4], d.dice[0..2])
		assert_not_equal(1, d.dice[3], @@reroll_msg)
		assert_not_equal(3, d.dice[4], @@reroll_msg)
		assert_not_equal([0,1,1,1,2,0,0], d.counts)
	end

	def test_find_positions
		d = Roll.new(4,3,2,1,5)
		assert_equal([1], d.find_positions_with_value(4))
		assert_equal([5], d.find_positions_with_value(5))
		d = Roll.new(1,3,2,1,1)
		assert_equal([1,4,5], d.find_positions_with_value(1))
	end

	def test_sum_dice
		d = Roll.new(4,3,2,1,5)
		assert_equal(15, d.sum_dice)
		d = Roll.new(1,1,1,1,1)
		assert_equal(5, d.sum_dice)
		d = Roll.new(6,6,6,6,6)
		assert_equal(30, d.sum_dice)
    end

    def test_best_score
    	s = ScoreSheet.new
    	# upper section
    	s.points[:three_of_a_kind] = 99
    	s.points[:four_of_a_kind] = 99
    	s.points[:yahtzee] = 99
    	s.points[:chance] = 99
    	# ones
    	d = Roll.new(1,1,1,2,1)  # 1 x 4
    	assert_equal([:ones, 4], s.find_best_score(d))

    	# twos
    	d = Roll.new(2,3,1,2,1)  # 2 x 2
    	assert_equal([:twos, 4], s.find_best_score(d))

    	# threes
    	d = Roll.new(1,3,1,2,3)  # 3 x 2
    	assert_equal([:threes, 6], s.find_best_score(d))

    	# fours
    	d = Roll.new(1,4,4,2,4)  # 4 x 3
    	assert_equal([:fours, 12], s.find_best_score(d))

    	# fives
    	d = Roll.new(5,5,5,5,5) # 5 x 5
    	assert_equal([:fives, 25], s.find_best_score(d))

    	# sixes
    	d = Roll.new(6,3,6,6,5) # 6 x 3
    	assert_equal([:sixes, 18], s.find_best_score(d))

    	# Lower section
    	# three of a kind
    	s = ScoreSheet.new
    	d = Roll.new(6,5,6,5,6) # three of a kind that's better than full house
    	assert_equal([:three_of_a_kind, 28], s.find_best_score(d))

    	# four of a kind
    	s = ScoreSheet.new
    	s.points[:three_of_a_kind] = 99
    	d = Roll.new(6,6,6,5,6)
    	assert_equal([:four_of_a_kind, 29], s.find_best_score(d))

    	# full house
    	s = ScoreSheet.new
    	d = Roll.new(3,3,5,5,3)
    	assert_equal([:full_house, 25], s.find_best_score(d))
	   	d = Roll.new(1,6,6,6,1)
    	assert_equal([:full_house, 25], s.find_best_score(d))

    	# small straight
    	s = ScoreSheet.new
    	d = Roll.new(1,2,6,3,4)
    	assert_equal([:small_straight, 30], s.find_best_score(d))
    	s.points[:large_straight] = 0  # zero out large straight
    	d = Roll.new(1,2,3,4,5)
    	assert_equal([:small_straight, 30], s.find_best_score(d))

    	# large straight
    	s = ScoreSheet.new
    	d = Roll.new(1,2,3,4,5)
    	assert_equal([:large_straight, 40], s.find_best_score(d))

    	# yahtzee
    	s = ScoreSheet.new
    	d = Roll.new(6,6,6,6,6)
    	assert_equal([:yahtzee, 50], s.find_best_score(d))
    	d = Roll.new(1,1,1,1,1)
    	assert_equal([:yahtzee, 50], s.find_best_score(d))

    end
end
