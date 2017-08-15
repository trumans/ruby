

def test(num)
   if num.is_a?(String) 
   	  raise "strings not allowed"
   end
   three = num % 3 == 0 
   four = num % 4 == 0
   r = ''
   if three || four then 
     r << "Foo" if three
     r << "bar" if four
    end
    r
end


(1..100).each do | num |
  #print test(num)
end

if test(3) == "Foo" then print "."; end
if test(4) == "bar" then print "."; end
if test(12) == "Foobar" then print "."; end
if test(5) != "Foo" then print "x"; end

str = "hello"
begin
  test(str)
rescue Exception => e
	print "strings not allowed"
end