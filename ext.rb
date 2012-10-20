class Array
	def delete_one y
		idx = find_index{|x| x == y}
		return if idx.nil?
		
		delete_at( idx )
	end
end