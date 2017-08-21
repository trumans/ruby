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

		# three of a kind
		d = Roll.new(4,3,3,5,3)
		assert_equal(18, d.score_three_of_a_kind)
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
		puts "Ones score: #{a.score_upper_category(1)}"
		puts "Twos score: #{a.score_upper_category(2)}"
		puts "Threes score: #{a.score_upper_category(3)}"
		puts "Fours score: #{a.score_upper_category(4)}"
		puts "Fives score: #{a.score_upper_category(5)}"
		puts "Sixes score: #{a.score_upper_category(6)}"
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
					puts " retry 1"
					eval fcn
				rescue
					begin
						puts " retry 2"
						eval fcn
					rescue
						begin
							puts " retry 3"
							eval fcn 
						rescue
							puts " retry 4"
							eval fcn
						end
					end
				end
			end
		}
	end

	def execute_reroll_1
		msg = "Re-run test as re-roll may have returned same value"
		puts "Execute_reroll_1"
		d = Roll.new(4,3,2,1,5)
		assert_equal([0,1,1,1,1,1,0], d.counts)
		d.reroll([2])
		assert_equal([4,3], d.dice[0..1])
		assert_not_equal(2, d.dice[2], msg)
		assert_equal([1,5], d.dice[3..4])
		assert_not_equal([0,1,1,1,1,1,0], d.counts)
	end

	def execute_reroll_2
		msg = "Re-run test as re-roll may have returned same value"
		puts "Execute_reroll_2"
		d = Roll.new(4,2,4,1,4)
		assert_equal([0,1,1,0,3,0,0], d.counts)
		d.reroll([4,4])
		assert_not_equal(4, d.dice[0], msg)
		assert_equal(2, d.dice[1])
		assert_not_equal(4, d.dice[2], msg)
		assert_equal([1,4], d.dice[3..4])
		assert_not_equal([0,1,1,0,3,0,0], d.counts)
	end

	def execute_reroll_3
		msg = "Re-run test as re-roll may have returned same value"
		puts "Execute_reroll_3"
		d = Roll.new(4,2,4,1,3)
		assert_equal([0,1,1,1,2,0,0], d.counts)
		d.reroll([1,3])
		assert_equal([4,2,4], d.dice[0..2])
		assert_not_equal(1, d.dice[3], msg)
		assert_not_equal(3, d.dice[4], msg)
		assert_not_equal([0,1,1,1,2,0,0], d.counts)
	end

	def test_find_indexes
		d = Roll.new(4,3,2,1,5)
		assert_equal([0], d.find_indexes(4))
		assert_equal([4], d.find_indexes(5))
		d = Roll.new(1,3,2,1,1)
		assert_equal([0,3,4], d.find_indexes(1))
	end

	def test_sum_dice
		d = Roll.new(4,3,2,1,5)
		assert_equal(15, d.sum_dice)
		d = Roll.new(1,1,1,1,1)
		assert_equal(5, d.sum_dice)
		d = Roll.new(6,6,6,6,6)
		assert_equal(30, d.sum_dice)
    end
end
