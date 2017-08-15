def pigLatinize(text)
	# split between words and non-words  numbers considered non-words
	words = text.scan(/([a-zA-Z]*)([^a-zA-Z]*)/)
	newStr = ''
	words.each do |t|
		word = t[0]
		delim = t[1]
		if word.length > 0
			# if start with vowel, then simply add 'way'
			if word.match(/^[aeiou]/i)
				suffix = (word == word.upcase ? "WAY" : "way")
				word += suffix
			else
				# if start with constant: parse starting blend or letter
				if word.match(/^(sch|scr|shr|sph|spl|squ|str|thr)/i)
					l = 3
				elsif word.match(/^(bl|br|ch|cl|cr|dr|fl|fr|gl|gr|pl|pr|qu|sc|sh|sk|sl|sm|sn|sp|st|sw|th|tr|tw|wh|wr)/i)
					l = 2
				else
					l = 1
				end
				first = word[0,l]
				rest = word[l, word.length-l]
				# adjust capitialization
				if word == word.upcase
					suffix = "AY"
				else
				 	suffix = "ay"
					if word[0] == word[0].upcase 
						first.downcase!; rest.capitalize!
					end
				end
				word = rest + first + suffix
			end
		end
		newStr = newStr + word + delim
	end
	return newStr
end

s = "! The quick brown fox007 Jumped Over (but not thru) the 3.1415 LAZY dog."
puts s
puts pigLatinize(s)