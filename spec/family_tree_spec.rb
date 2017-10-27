
require './family_tree'

# execute from command line with:
# bundle exec rspec

describe Tree do

	before(:all) do 
		@bad_tree = Tree.new
		# No parent or child assignment
		solo = @bad_tree.add_person(
			:alt_id => 'solo', :first_name => "Un", :last_name => "Connected")

		# simple parent and child relationship
		pa = @bad_tree.add_person(
			:alt_id => 'pa', :first_name => "Pa", :sex => "M")
		ma = @bad_tree.add_person(
			:alt_id => 'ma', :first_name => "Ma", :sex => "F")
		kid1 = @bad_tree.add_person(
			:alt_id => 'kid1', :first_name => "Kid 1", 
			:mother_id => ma.person_id, :father_id => pa.person_id)
		# parent ids are invalid. should not be assigned
		@kid2 = @bad_tree.add_person(
			:alt_id => 'kid2', :first_name => "Kid 2", 
			:mother_id => 103, :father_id => 102)

		@unconnected_ids = @bad_tree.unconnected.map { |p| p.alt_id }
	end

	# describe ... typically a method name
	#   context ... condition of the test
	#     it ...    test case / expected result
	#     it ...    test case

	describe '.unconnected' do
		it 'includes person never assigned parents or children' do
			expect(@unconnected_ids).to include 'solo'
		end
		it 'does not include person only a child or parent' do
			expect(@unconnected_ids).not_to include 'pa'
			expect(@unconnected_ids).not_to include 'kid1'
		end

	end

	describe 'attempt to assign invalid parent ids' do
		it 'results in nil parent ids' do
			expect(@bad_tree.people[@kid2.person_id].mother_id).to be_nil
			expect(@bad_tree.people[@kid2.person_id].father_id).to be_nil
		end
		it 'unconnected includes the person' do
			expect(@unconnected_ids).to include 'kid2'
		end
	end

end

describe Tree do

	before(:all) do 
		@bad_tree = Tree.new

		# assign valid parent id#s but to wrong sex
		pa = @bad_tree.add_person(
			:alt_id => 'pa', :first_name => "Pa", :sex => "M")
		ma = @bad_tree.add_person(
			:alt_id => 'ma', :first_name => "Ma", :sex => "F")
		kid1 = @bad_tree.add_person(
			:alt_id => 'kid1', :first_name => "Kid-One", 
			:mother_id => ma.person_id, :father_id => pa.person_id)
		kid2 = @bad_tree.add_person(
			:alt_id => 'kid2', :first_name => "Kid-Two", 
			:mother_id => pa.person_id, :father_id => ma.person_id)

		@results = @bad_tree.check_parental_integrity
		@issues = @results["issues"].join("|")
	end

	describe 'integrity check' do
		it 'has expected people count' do
			expect(@results["people"]).to eql 4
		end
		it 'identifies the parent sex mismatch' do
			expect(@results["issues"].size).to eql 2
			expect(@issues).to match(/kid2 .* has a mother pa .* who is male/)
			expect(@issues).to match(/kid2 .* has a father ma .* who is female/)
		end
	end

end

=begin
bad_tree = Tree.new

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
expect(results["issues"]).to be_include("person 6 is not in children list for mother id 2")
expect(results["issues"]).to be_include("person 6 is not in children list for father id 3")
expect(results["issues"]).to be_include("person 6 has invalid child id 999 in children list")
puts "Issues found"
puts results["issues"]
puts
=end
