
def list_sort(integers1, integers2)

  # return true if the value from integers1 (val1) is the lower 
  def use_list1?(val1, val2)
    return false if val1.nil?  #integers1 has no values left to process
    return true if val2.nil?   #integers2 has no values lest fo process
    return val1 < val2
  end

  index1 = 0
  index2 = 0
  # current1, current2 the the elements currently processed from integers1, integers2
  current1 = integers1[index1]
  current2 = integers2[index2]

  merged_list = []

  # index through both lists until all elements are processed
  while !current1.nil? or !current2.nil?
    if use_list1?(current1, current2)
      merged_list << current1
      index1 += 1
      current1 = integers1[index1]
    else 
      merged_list << current2
      index2 += 1
      current2 = integers2[index2]
    end
  end

  final_list = []
  removed_items = [] 

  for idx in (0...merged_list.length)
    if merged_list[idx].odd?
      removed_items << merged_list[idx]
    else
      final_list << merged_list[idx]
    end
  end
  puts "removed items #{removed_items}" if removed_items.length > 0

  final_list
end

#[1,4,6],[2,3,5] → [2,4,6].
print list_sort( [1,4,6], [2,3,5] )
print "\n\n"
print list_sort( [2,3,5], [1,4,6] )
print "\n\n"
print list_sort( [2,4,5], [1,4,6] )
print "\n\n"
print list_sort( [2,4,5], [1,6,6] )
print "\n\n"
print list_sort( [2,3,5], [1,4] )
print "\n\n"
print list_sort( [3,5], [1,4,6] )
print "\n\n"
print list_sort( [], [1,4,6] )
print "\n\n"
print list_sort( [1,3,5], [] )
print "\n\n"
print list_sort( [], [] )
print "\n\n"

#20045098695
#trumanwsmith
#1v w. C