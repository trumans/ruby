# Date Difference
require 'test/unit/assertions'
extend Test::Unit::Assertions

def date_difference(start_year, start_month, start_day,  end_year, end_month, end_day)

	def days_in(year, month)
		case month
		when 1,3,5,7,8,10,12
			31
		when 2
			# leap year if evenly divisible by 4 and not century, or by 400
			((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0) ? 29 : 28
		when 4,6,9,11
			30
		end
	end

	if start_year < 1583 || end_year < 1583
		puts 'warning: function may be incorrect earlier than 1583'
	end

	unless (end_year > start_year) ||
	       (end_year == start_year && end_month > start_month) ||
	       (end_year == start_year && end_month == start_month && end_day >= start_day)
		#puts 'end date cannot be earlier than start date'
		return nil
	end

	# dates within a year
	if start_year == end_year 
		if start_month == end_month
			return end_day - start_day
		else
			whole_months = (start_month+1..end_month-1).inject(0) do | total, month |
				total + days_in(start_year, month)
			end
			return days_in(start_year, start_month) - start_day + 
		    	   whole_months +
		       	   end_day
		end
	end

	# across multiple years
	whole_years = (start_year+1..end_year-1).inject(0) do | total, year |
		total + (days_in(year, 2) == 28 ? 365 : 366)
	end
	return date_difference(start_year, start_month, start_day,  
		                   start_year, 12, 31) + 
	       whole_years +
		   date_difference(end_year, 1, 1,  
		   	               end_year, end_month, end_day) + 1

end 

def display_diff(start_year, start_month, start_day, end_year, end_month, end_day)
	diff = date_difference(start_year, start_month, start_day, end_year, end_month, end_day)
	puts "days between #{start_year}-#{start_month}-#{start_day} and #{end_year}-#{end_month}-#{end_day} is #{diff}" if diff
end

assert_equal   13, date_difference(2016,  3,  2,  2016,  3, 15), ' ' # same the month
assert_equal   29, date_difference(2010,  9,  1,  2010,  9, 30), ' ' # whole month
assert_equal    1, date_difference(2016,  7, 15,  2016,  7, 16), ' ' # adjacent days
assert_equal    0, date_difference(2016,  2, 25,  2016,  2, 25), ' ' # same day
assert_equal   11, date_difference(2010,  3, 25,  2010,  4,  5), ' ' # adjacent months
assert_equal   36, date_difference(2010,  3, 25,  2010,  4, 30), ' ' # partial + whole month
assert_equal   31, date_difference(2010,  7,  1,  2010,  8,  1), ' ' # whole month + 1 day
assert_equal   42, date_difference(2010,  7, 25,  2010,  9,  5), ' ' # partial + whole + partial months
assert_equal   25, date_difference(2010,  2, 15,  2010,  3, 12), ' ' # adjacent months w/ regular Feb
assert_equal   26, date_difference(2016,  2, 15,  2016,  3, 12), ' ' # adjacent months w/ leap Feb
assert_equal  365, date_difference(2016,  1,  1,  2016, 12, 31), ' ' # whole year, leap year
assert_equal  364, date_difference(2001,  1,  1,  2001, 12, 31), ' ' # whole year, not leap year
assert_equal  365, date_difference(2000,  1,  1,  2000, 12, 31), ' ' # whole century year, leap year
assert_equal  364, date_difference(1900,  1,  1,  1900, 12, 31), ' ' # whole century year, not leap year
assert_equal  365, date_difference(2004,  3,  1,  2005,  3,  1), ' ' # past Feb in leap year
assert_equal  366, date_difference(1999,  3,  1,  2000,  3,  1), ' ' # wrap into leap year
assert_equal   12, date_difference(2001, 12, 25,  2002,  1,  6), ' ' # => 6 + 6
assert_equal  377, date_difference(2001, 12, 25,  2003,  1,  6), ' ' # => 6 + 365 + 6
assert_equal  378, date_difference(2003, 12, 25,  2005,  1,  6), ' ' # => 6 + 366 + 6
assert_equal 1132, date_difference(1996,  1, 25,  1999,  3,  2), ' ' # multi-year with a Feb 29
assert_equal 1498, date_difference(1996,  1, 25,  2000,  3,  2), ' ' # two Feb 29
puts "Assertions passed"
