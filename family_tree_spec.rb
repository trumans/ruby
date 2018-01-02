require_relative 'family_tree'
#require 'rspec/expectations'
require 'rspec'
include RSpec::Matchers

describe Tree do

	before do 
		@bad_tree = Tree.new
		ibm = @bad_tree.add_person(
			:alt_id => 'ibm', :first_name => "Int'l", :middle_name => "Biz", 
			:last_name => "Machines")
		pa = @bad_tree.add_person(
			:alt_id => 'pa', :first_name => "Pa", :sex => "M")
		ma = @bad_tree.add_person(
			:alt_id => 'ma', :first_name => "Ma", :sex => "F")
		# assign valid parent id#s but to wrong sex
		kid1 = @bad_tree.add_person(
			:first_name => "Kid 1", :mother_id => pa.person_id, 
			:father_id => ma.person_id)
	end

	describe 'unconnected' do
		context 'soemthing something' do
			it 'finds unconnected persons' do
				u_list = @bad_tree.unconnected.map do | p |
#					puts "#{p.person_id}: #{p.first_name} #{p.last_name}"
					p.alt_id
				end
				expect(['ibm']).to eql(u_list.sort)
				#expect(['ibm', kid2.person_id, ijk.person_id]).to eql(u_list.sort)
			end
		end
	end

end
=begin
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
=end
