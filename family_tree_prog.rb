require 'rspec/expectations'
include RSpec::Matchers
require_relative 'family_tree'

my_tree = Tree.new
puts "Add People"
#1
tj  = my_tree.add_person({:first_name => "Truman", :last_name => "Smith", :suffix => "Jr", :sex => "M", :birth_date => "1958-10-07"})
#2
mkp = my_tree.add_person({:first_name => "Martha", :last_name => "Smith", :sex => "F", :birth_date => "1964-07"})
#3
ts  = my_tree.add_person({:first_name => "Truman", :last_name => "Smith", :suffix => "(Sr)", :sex => "M", :birth_date => "1937-03-02"})
#4
mks = my_tree.add_person({:first_name => "Mary", :last_name => "Kahler", :sex => "F", :birth_date => "1936-09-02"})
#5
rs  = my_tree.add_person({:first_name => "Rosemary", :last_name => "Shoemaker", :prefix => "Dr.", :sex => "F"})
#6
wts = my_tree.add_person({:first_name => "Wilson", :middle_name => "Truman", :last_name => "Smith"})
#7
ap = my_tree.add_person({:first_name => "Ali", :last_name => "Paterson", :mother_id => 2, :father_id => 1})  # fix father id in update
#8
mrs = my_tree.add_person({:first_name => "Macielynn", :middle_name => "R", :last_name => "Smith", :sex => "F", :father_id => 6})
#9
eds = my_tree.add_person({:first_name => "Emmalee", :middle_name => "D", :last_name => "Smith", :sex => "F"})

puts my_tree.inspect_people
puts

puts "Update People"
my_tree.update_person(tj.person_id, {:father_id => ts.person_id, :mother_id => mks.person_id, :middle_name => "W", :children_ids => [6] })
my_tree.update_person(mkp.person_id, {:father_id => ts.person_id, :mother_id => mks.person_id, :last_name => "(Smith) Paterson"})
my_tree.update_person(mks.person_id, {:mother_id => rs.person_id})
my_tree.update_person(wts.person_id, {:sex => "M", :children_ids => [mrs.person_id,eds.person_id]})
puts my_tree.inspect_people
puts

def list_descendants(gen_list)
	gen_list.each_with_index do | gen, idx |
		gen.each do | person | 
			puts "gen #{idx}: #{person.full_name} - #{person.descendant_title(idx)}"
		end
	end
end

def list_ancestors(gen_list)
	gen_list.each_with_index do | gen, idx |
		gen.each do | person | 
			puts "gen #{idx}: #{person.full_name} - #{person.ancestor_title(idx)}"
		end
	end
end

puts "Descendants"
list_descendants(my_tree.descendants(rs.person_id))
puts "============="
list_descendants(my_tree.descendants(eds.person_id))
puts

puts "Ancestors"
list_ancestors(my_tree.ancestors(mrs.person_id))
puts "============="
list_ancestors(my_tree.ancestors(ts.person_id))
puts

"Add Marriages"
m1 = my_tree.add_marriage({:spouse1_id => ts.person_id, :spouse2_id => mks.person_id, :marriage_date => '1957-03'})
puts my_tree.inspect_marriages
puts

#my_tree.update_marriage(9999, {:marriage_date => "1957"})
"Update Marriages"
my_tree.update_marriage(m1.marriage_id, {:marriage_date => '1957-03-03'})
puts my_tree.inspect_marriages
puts

puts "Unconnected"
u = my_tree.unconnected.map
expect(u.size).to eq(0)
puts "No unconnected people found"
puts

puts "Parental Integrity"
r = my_tree.check_parental_integrity
expect(r["people"]).to eq(9)
expect(r["issues"].size).to eq(0)
puts "No issues found"
puts

puts "================="
puts "================="
puts "BAD TREE"
bad_tree = Tree.new
#1
ibm = bad_tree.add_person(:first_name => "International", :middle_name => "Business", :last_name => "Machines")
#2
pa = bad_tree.add_person(:first_name => "Pa", :sex => "M")
#3
ma = bad_tree.add_person(:first_name => "Ma", :sex => "F")
#4
# assign valid parent id#s but to wrong sex
kid1 = bad_tree.add_person(:first_name => "Kid 1", :mother_id => pa.person_id, :father_id => ma.person_id)

#5
puts "Expect 2 warnings that parents are invalid person id"
kid2 = bad_tree.add_person(:first_name => "Kid 2", :mother_id => 103, :father_id => 102)
expect(bad_tree.people[kid2.person_id].mother_id).to be_nil
expect(bad_tree.people[kid2.person_id].father_id).to be_nil

#6 - who violates checks in parental integrity method
xyz = bad_tree.add_person(:first_name => "xyz")
# copy another person with parents to this key, so that parents don't have 6 as their child
bad_tree.people[xyz.person_id] = bad_tree.people[kid1.person_id].clone
bad_tree.people[xyz.person_id].person_id = xyz.person_id
# add an invalid id to children list
bad_tree.people[xyz.person_id].children_ids << 999

#7 
puts "Expect warning that children list is ignored due to person's sex"
ijk = bad_tree.add_person(:first_name => "Gender", :last_name => "Unknown", :children_ids => [kid1.person_id])
expect(bad_tree.people[kid2.person_id].children_ids).to be_empty

puts "Expect warning person not updated due to invalid id"
bad_tree.update_person(9999, {:first_name => "ragu"})

puts
puts "* Unconnected *"
u_list = bad_tree.unconnected.map do | p |
	puts "#{p.person_id}: #{p.first_name} #{p.last_name}"
	p.person_id
end
expect([ibm.person_id, kid2.person_id, ijk.person_id]).to eql(u_list.sort)
puts

puts "* Parental Integrity *"
results = bad_tree.check_parental_integrity
expect(results["people"]).to eq(7)
expect(results["issues"].size).to eq(5)
expect(results["issues"]).to be_include("person 2 is not expected father_id for child 4")
expect(results["issues"]).to be_include("person 3 is not expected mother_id for child 4")
expect(results["issues"]).to be_include("person 6 is not in children list for mother id 2")
expect(results["issues"]).to be_include("person 6 is not in children list for father id 3")
expect(results["issues"]).to be_include("person 6 has invalid child id 999 in children list")
puts "Issues found"
puts results["issues"]
puts