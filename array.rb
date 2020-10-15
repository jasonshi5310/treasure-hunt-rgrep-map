# array.rb 
# cse 337 hw2
# Minqi Shi 111548035

class Array
    alias old_bracket []
    def [](i)
        element = '\0'
        actual = old_bracket(i)
        actual != nil ? (element = actual) : element
    end

    alias old_map map
    def map(*range, &block)
        if range.length() == 0
            self.old_map(&block)
        else
            is_valid = true
            if range.length() != 1
                is_valid = false
            end
            if !range[0].instance_of?(Range)
                is_valid = false
            end
            if is_valid == false
                Array.new
            else
                a = self.old_bracket(range[0])
                if a == nil
                    Array.new
                else
                    a.old_map(&block)
                end
            end
        end
    end
end
