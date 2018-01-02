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
		puts
		puts "Random roll: "
		a.print_roll
		puts "Counts: #{a.counts}"
		puts 
		puts "Ones score: #{a.score_upper_category(1)}"
		puts "Twos score: #{a.score_upper_category(2)}"
		puts "Threes score: #{a.score_upper_category(3)}"
		puts "Fours score: #{a.score_upper_category(4)}"
		puts "Fives score: #{a.score_upper_category(5)}"
		puts "Sixes score: #{a.score_upper_category(6)}"
		puts 
		puts "Full house: #{a.score_full_house}"
		puts "Small straight: #{a.score_small_straight}"
		puts "Large straight: #{a.score_large_straight}"
		puts "Three of a kind: #{a.score_three_of_a_kind}"
		puts "Four of a kind: #{a.score_four_of_a_kind}"
		puts "Yahtzee: #{a.score_yahtzee}"
		puts "Chance: #{a.score_chance}"
        puts
        p = a.probability_upper_category(1)
        puts("Minimum Ones probability is #{'%.2f' % p}% or 1 in #{'%d' % (100/p)}")
        p = a.probability_upper_category(2)
        puts("Minimum Twos probability is #{'%.2f' % p}% or 1 in #{'%d' % (100/p)}")
        p = a.probability_upper_category(3)
        puts("Minimum Threes probability is #{'%.2f' % p}% or 1 in #{'%d' % (100/p)}")
        p = a.probability_upper_category(4)
        puts("Minimum Fours probability is #{'%.2f' % p}% or 1 in #{'%d' % (100/p)}")
        p = a.probability_upper_category(5)
        puts("Minimum Fives probability is #{'%.2f' % p}% or 1 in #{'%d' % (100/p)}")
        p = a.probability_upper_category(6)
        puts("Minimum Sixes probability is #{'%.2f' % p}% or 1 in #{'%d' % (100/p)}")
        p = a.probability_three_of_a_kind
        puts("three-of-a-kind probability is #{'%.2f' % p}% or 1 in #{'%d' % (100/p)}")
        p = a.probability_four_of_a_kind
        puts("four-of-a-kind probability is #{'%.2f' % p}% or 1 in #{'%d' % (100/p)}")
        p = a.probability_full_house
        puts("full house probability is #{'%.2f' % p}% or 1 in #{'%d' % (100/p)}")
        p = a.probability_small_straight
        p = a.probability_yahtzee
        puts("yahtzee probability is #{'%.2f' % p}% or 1 in #{'%d' % (100/p)}")
	end

	# Execute each reroll test individually.  
	# Retry 4 times due to re-roll legitimately returning same value 
	def test_reroll
		["execute_reroll_1", 
		 "execute_reroll_2", 
         "execute_reroll_3", 
         "execute_reroll_4", 
         "execute_reroll_5", 
		 "execute_reroll_6"].each { |fcn|
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
	#     but there is a 1 in 6 change the rerolled returned the same value
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

    def execute_reroll_4
        d = Roll.new(4,3,2,1,5)
        assert_equal([0,1,1,1,1,1,0], d.counts)
        d.reroll_positions([3]) 
        assert_equal([4,3], d.dice[0..1])
        assert_not_equal(2, d.dice[2], @@reroll_msg)
        assert_equal([1,5], d.dice[3..4])
        assert_not_equal([0,1,1,1,1,1,0], d.counts)
    end

    def execute_reroll_5
        d = Roll.new(4,2,4,1,4)
        assert_equal([0,1,1,0,3,0,0], d.counts)
        d.reroll_positions([1,3])
        assert_not_equal(4, d.dice[0], @@reroll_msg)
        assert_equal(2, d.dice[1])
        assert_not_equal(4, d.dice[2], @@reroll_msg)
        assert_equal([1,4], d.dice[3..4])
        assert_not_equal([0,1,1,0,3,0,0], d.counts)
    end

    def execute_reroll_6
        d = Roll.new(4,2,4,1,3)
        assert_equal([0,1,1,1,2,0,0], d.counts)
        d.reroll_positions([4,5])
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

    def test_rank_open_categories
        # Common steps:
        #   create a score sheet
        #   assign points to selected categories to 
        #     1) test skipping already scored categores
        #     2) avoid two categories with same score
        #   create a dice roll
        #   get ranking for open categories
        #   assert the number of category scores returned
        #   assert the expected categories are the top scores
        #   assert the zero-score categories are present

    	s = ScoreSheet.new
    	s.points[:yahtzee] = 0

    	# upper section
    	d = Roll.new(2,3,1,2,1)
    	r = s.rank_open_categories(d).to_a
    	assert_equal(r.size, 12)
    	assert_equal(r[0], [:chance, 9])
    	assert_equal(r[1], [:twos, 4])
    	assert_equal(r[2], [:threes, 3])
    	assert_equal(r[3], [:ones, 2])
    	assert(r.include?([:fours, 0]))
    	assert(r.include?([:fives, 0]))
    	assert(r.include?([:sixes, 0]))
    	assert(r.include?([:three_of_a_kind, 0]))
    	assert(r.include?([:four_of_a_kind, 0]))
    	assert(r.include?([:full_house, 0]))
    	assert(r.include?([:small_straight, 0]))
    	assert(r.include?([:large_straight, 0]))
		# yahztee not included since not open

    	s = ScoreSheet.new
    	s.points[:yahtzee] = 0
    	s.points[:chance] = 99
    	d = Roll.new(6,4,4,5,4)
    	r = s.rank_open_categories(d).to_a
    	assert_equal(r.size, 11)
    	assert_equal(r[0], [:three_of_a_kind, 23])
    	assert_equal(r[1], [:fours, 12])
    	assert_equal(r[2], [:sixes, 6])
    	assert_equal(r[3], [:fives, 5])
    	assert(r.include?([:ones, 0]))
    	assert(r.include?([:twos, 0]))
    	assert(r.include?([:threes, 0]))
    	assert(r.include?([:four_of_a_kind, 0]))
    	assert(r.include?([:full_house, 0]))
    	assert(r.include?([:small_straight, 0]))
    	assert(r.include?([:large_straight, 0]))
		# yahztee, chance not included since not open

    	# Lower section
    	s = ScoreSheet.new
    	s.points[:chance] = 99

    	# three-of-a-kind, full house
    	d = Roll.new(6,5,6,5,6) 
    	r = s.rank_open_categories(d).to_a
    	assert_equal(r.size, 12)
    	assert_equal(r[0], [:three_of_a_kind,28])
    	assert_equal(r[1], [:full_house, 25])
    	assert_equal(r[2], [:sixes, 18])
    	assert_equal(r[3], [:fives, 10])
    	assert(r.include?([:ones, 0]))
    	assert(r.include?([:twos, 0]))
    	assert(r.include?([:threes, 0]))
    	assert(r.include?([:fours, 0]))
    	assert(r.include?([:four_of_a_kind, 0]))
    	assert(r.include?([:small_straight, 0]))
    	assert(r.include?([:large_straight, 0]))
    	assert(r.include?([:yahtzee, 0]))

    	d = Roll.new(5,5,4,4,4) 
    	r = s.rank_open_categories(d).to_a
    	assert_equal(r.size, 12)
    	assert_equal(r[0], [:full_house, 25])
    	assert_equal(r[1], [:three_of_a_kind, 22])
    	assert_equal(r[2], [:fours, 12])
    	assert_equal(r[3], [:fives, 10])
    	assert(r.include?([:ones, 0]))
    	assert(r.include?([:twos, 0]))
    	assert(r.include?([:threes, 0]))
    	assert(r.include?([:sixes, 0]))
    	assert(r.include?([:four_of_a_kind, 0]))
    	assert(r.include?([:small_straight, 0]))
    	assert(r.include?([:large_straight, 0]))
    	assert(r.include?([:yahtzee, 0]))

    	# four-of-a-kind
    	s = ScoreSheet.new
    	s.points[:three_of_a_kind] = 99
    	s.points[:chance] = 99
    	d = Roll.new(6,6,6,5,6)
    	r = s.rank_open_categories(d).to_a
    	assert_equal(r.size, 11)
    	assert_equal(r[0], [:four_of_a_kind,29])
    	assert_equal(r[1], [:sixes, 24])
    	assert_equal(r[2], [:fives, 5])
    	assert(r.include?([:ones, 0]))
    	assert(r.include?([:twos, 0]))
    	assert(r.include?([:threes, 0]))
    	assert(r.include?([:fours, 0]))
    	assert(r.include?([:full_house, 0]))
    	assert(r.include?([:small_straight, 0]))
    	assert(r.include?([:large_straight, 0]))
    	assert(r.include?([:yahtzee, 0]))

    	# small straight
    	s = ScoreSheet.new
    	d = Roll.new(1,2,6,3,4)
    	r = s.rank_open_categories(d).to_a
    	assert_equal(r.size, 13)
    	assert_equal(r[0], [:small_straight, 30])
    	assert_equal(r[1], [:chance, 16])
    	assert_equal(r[2], [:sixes, 6])
    	assert_equal(r[3], [:fours, 4])
    	assert_equal(r[4], [:threes, 3])
    	assert_equal(r[5], [:twos, 2])
    	assert_equal(r[6], [:ones, 1])
    	assert(r.include?([:fives, 0]))
    	assert(r.include?([:three_of_a_kind, 0]))
    	assert(r.include?([:four_of_a_kind, 0]))
    	assert(r.include?([:full_house, 0]))
    	assert(r.include?([:large_straight, 0]))
    	assert(r.include?([:yahtzee, 0]))

    	# small straight, large straight
    	d = Roll.new(1,2,3,4,5)
    	r = s.rank_open_categories(d).to_a
    	assert_equal(r.size, 13)
    	assert_equal(r[0], [:large_straight, 40])
    	assert_equal(r[1], [:small_straight, 30])
    	assert_equal(r[2], [:chance, 15])
    	assert_equal(r[3], [:fives, 5])
    	assert_equal(r[4], [:fours, 4])
    	assert_equal(r[5], [:threes, 3])
    	assert_equal(r[6], [:twos, 2])
    	assert_equal(r[7], [:ones, 1])
    	assert(r.include?([:sixes, 0]))
    	assert(r.include?([:three_of_a_kind, 0]))
    	assert(r.include?([:four_of_a_kind, 0]))
    	assert(r.include?([:full_house, 0]))
    	assert(r.include?([:yahtzee, 0]))

    	# yahtzee
    	s = ScoreSheet.new
    	s.points[:chance]=99
    	s.points[:three_of_a_kind]=99
    	s.points[:four_of_a_kind]=99
    	d = Roll.new(6,6,6,6,6)
    	r = s.rank_open_categories(d).to_a
    	assert_equal(r.size, 10)
    	assert_equal(r[0], [:yahtzee, 50])
    	assert_equal(r[1], [:sixes, 30])
    	assert(r.include?([:ones, 0]))
    	assert(r.include?([:twos, 0]))
    	assert(r.include?([:threes, 0]))
    	assert(r.include?([:fours, 0]))
    	assert(r.include?([:fives, 0]))
    	assert(r.include?([:full_house, 0]))
    	assert(r.include?([:small_straight, 0]))
    	assert(r.include?([:large_straight, 0]))

    	# yahtzee, four-of-a-kind
    	s = ScoreSheet.new
    	s.points[:chance]=99
    	s.points[:three_of_a_kind]=99
    	s.points[:ones]=99
    	d = Roll.new(1,1,1,1,1)
    	r = s.rank_open_categories(d).to_a
    	assert_equal(r.size, 10)
    	assert_equal(r[0], [:yahtzee, 50])
    	assert_equal(r[1], [:four_of_a_kind, 5])
    	assert(r.include?([:twos, 0]))
    	assert(r.include?([:threes, 0]))
    	assert(r.include?([:fours, 0]))
    	assert(r.include?([:fives, 0]))
    	assert(r.include?([:sixes, 0]))
    	assert(r.include?([:full_house, 0]))
    	assert(r.include?([:small_straight, 0]))
    	assert(r.include?([:large_straight, 0]))

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
    	assert_equal([:ones, 4], d.find_best_score(s))

    	# twos
    	d = Roll.new(2,3,1,2,1)  # 2 x 2
    	assert_equal([:twos, 4], d.find_best_score(s))

    	# threes
    	d = Roll.new(1,3,1,2,3)  # 3 x 2
    	assert_equal([:threes, 6], d.find_best_score(s))

    	# fours
    	d = Roll.new(1,4,4,2,4)  # 4 x 3
    	assert_equal([:fours, 12], d.find_best_score(s))

    	# fives
    	d = Roll.new(5,5,5,5,5) # 5 x 5
    	assert_equal([:fives, 25], d.find_best_score(s))

    	# sixes
    	d = Roll.new(6,3,6,6,5) # 6 x 3
    	assert_equal([:sixes, 18], d.find_best_score(s))

    	# Lower section
    	# three of a kind
    	s = ScoreSheet.new
    	d = Roll.new(6,5,6,5,6) # three of a kind that's better than full house
    	assert_equal([:three_of_a_kind, 28], d.find_best_score(s))

    	# four of a kind
    	s = ScoreSheet.new
    	s.points[:three_of_a_kind] = 99
    	d = Roll.new(6,6,6,5,6)
    	assert_equal([:four_of_a_kind, 29], d.find_best_score(s))

    	# full house
    	s = ScoreSheet.new
    	d = Roll.new(3,3,5,5,3)
    	assert_equal([:full_house, 25], d.find_best_score(s))
	   	d = Roll.new(1,6,6,6,1)
    	assert_equal([:full_house, 25], d.find_best_score(s))

    	# small straight
    	s = ScoreSheet.new
    	d = Roll.new(1,2,6,3,4)
    	assert_equal([:small_straight, 30], d.find_best_score(s))
    	s.points[:large_straight] = 0  # zero out large straight
    	d = Roll.new(1,2,3,4,5)
    	assert_equal([:small_straight, 30], d.find_best_score(s))

    	# large straight
    	s = ScoreSheet.new
    	d = Roll.new(1,2,3,4,5)
    	assert_equal([:large_straight, 40], d.find_best_score(s))

    	# yahtzee
    	s = ScoreSheet.new
    	d = Roll.new(6,6,6,6,6)
    	assert_equal([:yahtzee, 50], d.find_best_score(s))
    	d = Roll.new(1,1,1,1,1)
    	assert_equal([:yahtzee, 50], d.find_best_score(s))
    end

    def test_probability_calc
        puts
        s = ScoreSheet.new
        d = Roll.new(6,6,6,6,6)
        d.probability_yahtzee
        d.probability_full_house
        d.probability_small_straight
        puts
        d = Roll.new(6,5,4,3,2)
        d.probability_yahtzee
        d.probability_full_house
        d.probability_small_straight
        puts
        d = Roll.new(4,5,4,3,3)
        d.probability_yahtzee
        d.probability_full_house
        d.probability_small_straight
        puts
        d = Roll.new(5,5,4,4,2)
        d.probability_yahtzee
        d.probability_full_house
        d.probability_small_straight
        puts
    end

    def test_print_score_sheet
    	s = ScoreSheet.new
    	s.points[:ones] = 1 * 1
    	s.points[:twos] = 2 * 4
    	s.points[:threes] = 3 * 3
    	s.points[:fours] = 4 * 2
       	s.points[:fives] = 5 * 4
       	s.points[:sixes] = 6 * 3
    	s.points[:three_of_a_kind] = (3*3) + 2 + 4
    	s.points[:four_of_a_kind] = (4*5) + 1 + 3
    	puts
    	puts "Scoresheet with set values"
    	s.print_score_sheet
    end

    def test_permutatons
        expected_perms = [[3,4], [4,3]]
        p = Permutations.for_array([3,4])
        assert_equal(expected_perms.length, p.length)
        expected_perms.each { |perm| 
            assert(p.include?(perm), "permutation #{perm} not found in #{p}")
        }

        expected_perms = 
            [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]]
        p = Permutations.for_array([1,2,3])
        assert_equal(expected_perms.length, p.length)
        expected_perms.each { |perm| 
            assert(p.include?(perm), "permutation #{perm} not found in #{p}")
        }

        p = Permutations.for_array([1,2,3,4])
        assert_equal(24, p.length)

        expected_perms = [[1],[2],[3],[4],[5],[6]]
        p = Permutations.for_dice(1)
        assert_equal(expected_perms, p)

        expected_perms = 
            [[1, 1], [1, 2], [1, 3], [1, 4], [1, 5], [1, 6], 
             [2, 1], [2, 2], [2, 3], [2, 4], [2, 5], [2, 6], 
             [3, 1], [3, 2], [3, 3], [3, 4], [3, 5], [3, 6], 
             [4, 1], [4, 2], [4, 3], [4, 4], [4, 5], [4, 6], 
             [5, 1], [5, 2], [5, 3], [5, 4], [5, 5], [5, 6], 
             [6, 1], [6, 2], [6, 3], [6, 4], [6, 5], [6, 6]]
        p = Permutations.for_dice(2)
        assert_equal(6*6, p.length)
        expected_perms.each { |perm|
            assert(p.include?(perm), "permutation #{perm} not found in #{p}")
        }

        p = Permutations.for_dice(3)
        assert_equal(6*6*6, p.length)

        # Useful_rolls methd
        expected_perms = 
            [[1, 2, 1], [1, 1, 2], [2, 1, 1], 
             [1, 2, 2], [2, 1, 2], [2, 2, 1], 
             [1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1], 
             [1, 2, 4], [1, 4, 2], [2, 1, 4], [2, 4, 1], [4, 1, 2], [4, 2, 1], 
             [1, 2, 5], [1, 5, 2], [2, 1, 5], [2, 5, 1], [5, 1, 2], [5, 2, 1], 
             [1, 2, 6], [1, 6, 2], [2, 1, 6], [2, 6, 1], [6, 1, 2], [6, 2, 1]]    
        u = Permutations.useful_rolls([1,2], 3)
        assert_equal(expected_perms.length, u.length)
        expected_perms.each { |perm|
            assert(p.include?(perm), "permutation #{perm} not found in #{p}")
        }

        u = Permutations.useful_rolls([6,5], 4)
        assert_equal(302, u.length)
    end
end
