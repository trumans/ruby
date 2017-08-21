#Roman Numbers

def arabic_to_roman(text)

	# Convert a signle Arabic digit to Roman numberals
	# digit: a single arabic digit [0-9]
	# one: roman character for a one unit in the position
	# five: roman character for five units in the position
	# ten: roman character for ten units, to construct 9
	def convert_digit(digit, one, five, ten)
 	    case digit 
 	    when '0'
 	    	''
	    when '1'
	    	one
	    when '2'
	       	one + one
	    when '3'
	    	one + one + one
		when '4'
	    	one + five
		when '5'
		    five
	    when '6'
		    five + one
		when '7'
	    	five + one + one
		when '8'
		    five + one + one + one
	    when '9'
		    one + ten
		end
	end

	return text if text.size > 4
	return (-text.size..-1).inject("") { |ret, idx|
		ret + 
			case idx
			when -1  # ones position
				convert_digit(text[-1], "I", "V", "X")
			when -2  # tens position
				convert_digit(text[-2], "X", "L", "C")
			when -3  # hundred position
				convert_digit(text[-3], "C", "D", "M") 
			when -4  # thousands
				convert_digit(text[-4], "M", "v", "x") 
			end
		}
end

def roman_to_arabic(text)

  # convert a single Roman numberal digit into an integer
  def numeral_value(digit)
  	case digit
  	when 'I'
  		1
  	when 'V'
  		5
  	when 'X'
  		10
  	when 'L'
  		50
  	when 'C'
  		100
  	when 'D'
  		500
  	when 'M'
  		1000
  	when 'v'
  		5000
  	when 'x'
  		10000
  	else
  		0
  	end
  end

  # process Roman numerals right-to-left
  (-1.downto(-text.size)).inject(0) { |val, idx|
  	if idx == -1
  		numeral_value(text[-1])
  	else
  		num = numeral_value(text[idx])
  		prev_num = numeral_value(text[idx+1]) # the previous digit
  		if num >= prev_num
  			val + num
  		else
  			val - num
  		end
  	end
  }
end


def convert(text)
	if text.match(/^[0-9]+$/)
		return arabic_to_roman(text)
	elsif text.match(/^[IVXLCDMvx]+$/)
		return roman_to_arabic(text)
	else
		return nil
	end
end

numbers = 
[["2", "II"], 
 ["5", "V"], 
 ["8", "VIII"], 
 ["9", "IX"],
 ["98", "XCVIII"],
 ["100", "C"],
 ["800","DCCC"],
 ["999", "CMXCIX"],
 ["1988", "MCMLXXXVIII"],
 ["4999", "MvCMXCIX"],
 ["9000", "Mx"]
]

numbers.each { |pair| 
    n = pair[0]
    r = convert(n)    
	print "#{n} converts to #{r}."
	print " ('v' used for 5000)" if r.include?('v')
	print " ('x' used for 10000)" if r.include?('x')
	print "  Expected #{pair[1]}" if r != pair[1]
	print  
	puts
	n = pair[1]
    a = convert(n).to_s    
	print "#{n} converts to #{a}."
	print " ('v' used for 5000)" if n.include?('v')
	print " ('x' used for 10000)" if n.include?('x')
	print "  Expected #{pair[0]}" if a != pair[0]
	puts
}
