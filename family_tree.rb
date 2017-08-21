
class Fixnum
	def to_ordinal
		str = self.to_s
		case str[-1]
    	when "1" then "#{str}st"
        when "2" then "#{str}nd"
	    when "3" then "#{str}rd"
    	else          "#{str}th"
      	end
 	end
end

class Tree
	attr_reader :people
	def initialize
		@next_person_id = 1
		@next_marriage_id = 1
		@people = {}
		@marriages = []
	end

	# People records
	def assign_next_person_id
		@next_person_id += 1
		@next_person_id - 1
	end

	def add_person(attributes)
		p = Person.new(assign_next_person_id, attributes)
		@people[p.person_id] = p
		update_parents(p.person_id, attributes)
		p
	end

	def update_person(person_id, attributes)
		if !@people.key?(person_id)
			puts "warning: no update to #{person_id}.  invalid person id."
		else
			@people[person_id].update(attributes)
			update_parents(person_id, attributes)
			@people[person_id]
		end
	end

	# Update a person's parents and/or children list
	# works on the :father_id, :mother_id or :children_ids values in attributes.
	# When father_id or mother_id is updated, also updates the parents' children_ids list.
    # When children_ids list is updated, also updates the children's father_id or mother_id.
	def update_parents(person_id, attributes)
		if attributes.include?(:father_id) then
	    	new_father_id = attributes[:father_id]
	    	if new_father_id and !@people.key?(new_father_id)
	    		puts "warning: update person #{person_id} - ignored invalid father_id #{new_father_id}."
	    	else
	    		# delete the person from the previous father
	    		old_father_id = @people[person_id].father_id
	    		@people[old_father_id].children_ids.delete(person_id) if old_father_id
	    		# add the person to the new father
	    		@people[new_father_id].children_ids << person_id if new_father_id
	    		# set the new father id to the child
	    		@people[person_id].father_id = new_father_id
	    	end
	    end   
	    if attributes.include?(:mother_id) then
	    	new_mother_id = attributes[:mother_id]
	    	if new_mother_id and !@people.key?(new_mother_id)
	    		puts "warning: update person #{person_id} - ignored invalid mother_id #{new_mother_id}."
	    	else
	    		# delete the person from the previous mother
			    old_mother_id = @people[person_id].mother_id
	    		@people[old_mother_id].children_ids.delete(person_id) if old_mother_id
	    		# add the person to the new mother
	    		@people[new_mother_id].children_ids << person_id if new_mother_id
	    		# set the new mother id to the person
			    @people[person_id].mother_id = new_mother_id
	    	end
	    end 
	    if attributes.include?(:children_ids) then
	    	new_children_ids = attributes[:children_ids]
	    	old_children_ids = @people[person_id].children_ids
	    	add_list    = new_children_ids - old_children_ids  # children to add to this person
	    	remove_list = old_children_ids - new_children_ids  # children to delete from this person
	    	case @people[person_id].sex  # determine if this person is a father or mother
	    	when "M", "F"
	    		@people[person_id].sex == "M" ? parent_type = :father_id : parent_type = :mother_id
	    		add_list.each    { | child | update_parents( child, { parent_type => person_id } ) }
	    		remove_list.each { | child | update_parents( child, { parent_type => nil } ) }
	    	else
	    		puts "warning: update person #{person_id} - ignored children due to invalid sex #{@people[person_id].sex}"
	    	end
	    end
	end

	def inspect_people(options=[])
		@people.inject("") { | everyone, person | 
			if options.include?(:supress_empty)
				everyone << "#{person[1].inspect_not_empty}\n"
			else
				everyone << "#{person.inspect}\n"
			end
			everyone }
	end

	# Return an array of persons where each element is an array of persons 
	# that are children of the previous element.
	# Element 0 is the person whose id is the argument
	def descendants(person_id)
		# initialize descendant with person as the first element
		descendants_list = [] << [@people[person_id]]
		parent_gen_idx = 0
		begin   
			next_gen = []
			# for each person in this generation, find their children
			descendants_list[parent_gen_idx].each do | parent |
				parent.children_ids.map { | id | next_gen << @people[id] }
			end
			# add new generation as another element to the descendants
			descendants_list << next_gen
			parent_gen_idx += 1
		end until next_gen.size == 0 # loop as long as another generation is returned
		descendants_list
	end

	# Return an array of persons where each element is an array of persons 
	# that are parents of the previous element.
	# Element 0 is the person whose id is the argument
	def ancestors(person_id)
		#intialize ancestors with person as the first element
		ancestors_list = [] << [@people[person_id]]
		child_gen_idx = 0
		begin
			next_gen = []
			#for each person in this generation, add their parents
			ancestors_list[child_gen_idx].each do | child |
				next_gen << @people[child.father_id] if child.father_id
				next_gen << @people[child.mother_id] if child.mother_id
			end
			ancestors_list << next_gen
			child_gen_idx += 1
		end until next_gen.size == 0
		ancestors_list
	end

	# persons with no parents or children
	def unconnected
		u = @people.select do | key, person |
			person.father_id == nil and person.mother_id == nil and
			person.children_ids == []
		end 
		u.map { | key, person | person }		
	end

    # Marriage records
	def assign_next_marriage_id
		@next_marriage_id += 1
		@next_marriage_id - 1
	end

	def add_marriage(attributes)
		m = Marriage.new(assign_next_marriage_id, attributes)
		@marriages.push(m)
		m
	end

	def find_marriage(marriage_id)
		idx = @marriages.index { | m | marriage_id == m.marriage_id }
		if idx then
			idx
		else
			raise Exception.new("update_marriage: invalid marriage_id #{marriage_id}")
		end
	end

	def find_marriages(person_id)
		(0...@marriages.length).select { | i | person_id == m[i].spouse1_id or person_id == m[i].spouse2_id }
	end

	def update_marriage(marriage_id, attributes)
		i = find_marriage(marriage_id)
		
		@marriages[i].update(attributes)
	end

	def inspect_marriages
		@marriages.inject("") { | all_couples, one_couple | all_couples << "#{one_couple.inspect}\n"; all_couples }
	end

	def check_parental_integrity
		def format_issue(person, msg)
			"person #{person.person_id} " + msg
		end
		res = {}  # results to be returned
		issues = [] # list of issues
		pc = 0  # count of person records processed
		@people.each do | key, person |
			pc += 1
			# does mother and father list this person as a child?
			if person.mother_id and !@people[person.mother_id].children_ids.include?(person.person_id)
				issues << format_issue(person, "is not in children list for mother id #{person.mother_id}")
			end
			if person.father_id and !@people[person.father_id].children_ids.include?(person.person_id)
				issues << format_issue(person, "is not in children list for father id #{person.father_id}")
			end
			# does each child list person as a parent?
			person.children_ids.each do | child_id |
				if @people.key?(child_id)
					case person.sex
					when "M"
						if @people[child_id].father_id != person.person_id
							issues << format_issue(person, "is not expected father_id for child #{child_id}")
						end
					when "F"
						if @people[child_id].mother_id != person.person_id
							issues << format_issue(person, "is not expected mother_id for child #{child_id}")
						end
					end
				else
					issues << format_issue(person, "has invalid child id #{child_id} in children list")
				end	
			end 
		end
		res["people"] = pc
		res["issues"] = issues
		res
	end

end

class Person
	attr_accessor :person_id, :father_id, :mother_id, :prefix, :first_name, 
	              :middle_name, :last_name, :suffix, :sex, :birth_date, 
	              :death_date, :children_ids
	def initialize(person_id, vals)
		@person_id    = person_id
 		@prefix       = vals.include?(:prefix)      ? vals[:prefix]      : "" 
 		@first_name   = vals.include?(:first_name)  ? vals[:first_name]  : "unk" 
 		@middle_name  = vals.include?(:middle_name) ? vals[:middle_name] : ""
		@last_name    = vals.include?(:last_name)   ? vals[:last_name]   : "unk"
 		@suffix       = vals.include?(:suffix)      ? vals[:suffix]      : "" 
	    @sex          = vals.include?(:sex)         ? vals[:sex]         : "unk"
	    @birth_date   = vals.include?(:birth_date)  ? vals[:birth_date]  : ""
	    @death_date   = vals.include?(:death_date)  ? vals[:death_date]  : ""
	    @father_id    = nil
		@mother_id    = nil
	    @children_ids = []
	end

	def update(vals)
 		@prefix      = vals[:prefix]      if vals.include?(:prefix)
 		@first_name  = vals[:first_name]  if vals.include?(:first_name)
 		@middle_name = vals[:middle_name] if vals.include?(:middle_name)
		@last_name   = vals[:last_name]   if vals.include?(:last_name)
 		@suffix      = vals[:suffix]      if vals.include?(:suffix)
	    @sex         = vals[:sex]         if vals.include?(:sex)
		@birth_date  = vals[:birth_date]  if vals.include?(:birth_date)
	    @death_date  = vals[:death_date]  if vals.include?(:death_date)
	end

	def full_name
		n = [ @prefix, @first_name, @middle_name, @last_name, @suffix ]
		n.select { | s | s.size != 0 }.join(" ") 
	end

	def clone
		c = self.dup
		c.children_ids = self.children_ids.dup
		c
	end

	def inspect_not_empty
		self.instance_variables.inject("\n") { | all_vars, var_name |
			val = self.instance_variable_get(var_name)
			not_empty = 
			    case val
			    when String, Array
			        !val.empty?
			    else
				    !val.nil?
			    end
			all_vars << "#{var_name}: #{val}\n" if not_empty
			all_vars 
		}
	end

	def inspect
		self.instance_variables.inject("\n") { | all_vars, var_name |
			all_vars << "#{var_name}: #{self.instance_variable_get(var_name)}\n"
			all_vars 
		}
	end

	# title for an ancestor 'generations' away
	def ancestor_title(generation=1)
		title = case self.sex
		when "M" then "father"
		when "F" then "mother"
		else          "parent"
		end

		case generation
		when 0 then "self"
		when 1 then title
		when 2 then "grand" + title
		when 3 then "great-grand" + title
		else (generation-2).to_ordinal + " great-grand" + title
		end
	end

	def descendant_title(generation=1)
		title = case self.sex
		when "M"; "son"
		when "F"; "daughter"
		else      "child"
		end

		case generation
		when 0 then "self"
		when 1 then title
		when 2 then "grand" + title
		when 3 then "great-grand" + title
		else (generation-2).to_ordinal + " great-grand" + title
		end
	end

end

class Marriage
	attr_reader :marriage_id, :spouse1_id, :spouse2_id, :marriage_date
	def initialize(marriage_id, vals)
		@marriage_id   = marriage_id
		@spouse1       = vals.include?(:spouse1_id)    ? vals[:spouse1_id]    : nil
		@spouse2       = vals.include?(:spouse2_id)    ? vals[:spouse2_id]    : nil
		@marriage_date = vals.include?(:marriage_date) ? vals[:marriage_date] : ""
	end

	def update(vals)
		@spouse1       = vals[:spouse1_id]    if vals.include?(:spouse1_id)
		@spouse2       = vals[:spouse2_id]    if vals.include?(:spouse2_id)
		@marriage_date = vals[:marriage_date] if vals.include?(:marriage_date)
	end

end
