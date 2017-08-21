
# Binary Search Tree
class Binary_search_tree
	attr_accessor :root, :tree

	def initialize()
		@root = nil
		@tree = {}
	end

    def inspect_pretty
    	return "root: #{@root}\n" + 
          @tree.inject("") { |ret, node|  
          	ret + "node key: #{node[0]}, left: #{node[1].left}, right: #{node[1].right}\n" }
    end

	def add_value(value)
		# empty tree.
		if @root == nil
			@root = value
			@tree = { value => Node.new(nil, nil) }
			return
		end

        # find approprate parent node for the value 
		parent = find_node(value)
		if parent != value
			# attach the value to the parent
			if value < parent
				@tree[parent].left = value
			else
				@tree[parent].right = value
			end
			#create new leaf with the value
			@tree[value] = Node.new(nil, nil)
		else
			# value is already in tree.  nothing to add
 		end
	end

    # returns value if value is in the tree
    # otherwises return the potential parent node
	def find_node(value)
		current_node = @root
		#puts "In find_node: current_node=#{current_node}, value=#{value}" 
		while true
			#puts "in find_node: current_node=#{current_node}, value=#{value}"
			# value is in tree
			if current_node == value  
				return value
			# value might be on left side of node
			elsif value < current_node  
				# if node is a leaf return the current node
				if @tree[current_node].left == nil
					return current_node
				# otherwise continue to the left side
				else
					current_node = @tree[current_node].left
				end
			# value might be on right side of node
			else
				# if node is a leaf return the current node
				if @tree[current_node].right == nil
					return current_node
				# otherwise continue to the right side
				else
					current_node = @tree[current_node].right
				end
			end
		end
	end


    # return list of nodes from a node to a value
    # will raise an exception of value is not in tree
    def find_chain(value, node)
    	if node == nil
    		raise "node argument is nil.  is value #{value} not in the tree?"
    	end

    	# the value was found
    	if value == node
    		return [value]
    	end

    	# raise an exception if this is a leaf
    	if !@tree.key?(node)
            raise "reached leaf #{node} without finding value #{value}"
        end

    	if value == @tree[node].left || value == @tree[node].right
    		return [node]
        end

        if value < node
        	return [node] + find_chain(value, @tree[node].left)
        end

        if value > node
           	return [node] + find_chain(value, @tree[node].right)
        end

        raise "Shouldn't get here! ???"
    end

    # Lowest Common Ancestor
    def lca(val1, val2)
    	chain1 = find_chain(val1, @root)
    	puts "chain1: #{chain1}"
    	chain2 = find_chain(val2, @root)
    	puts "chain2: #{chain2}"
    	inter = chain1 & chain2
    	puts "intersection is #{inter}"
    	inter.last
    end
end

class Node
	attr_accessor :left, :right
    def initialize(left, right)
  	  @left = left
  	  @right = right
    end
end

#t = Binary_search_tree.new(20, 
#                          {20 => Node.new(8, 22),
#	                        8  => Node.new(4, 12),
#                           12 => Node.new(10,14),
#	                        })

t = Binary_search_tree.new()
t.add_value(20)
t.add_value(8)
t.add_value(22)
t.add_value(4)
t.add_value(12)
t.add_value(10)
t.add_value(14)
puts t.inspect
puts t.inspect_pretty
puts
puts "LCA of 10,14 returns #{t.lca(10,14)}.  should be 12"
puts "LCA of 4,22 returns #{t.lca(4,22)}.  should be 20"
puts "LCA of 13,22 should raise an exception."
puts "#{t.lca(13,22)}"
