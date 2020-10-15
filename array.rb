# array.rb 
# cse 337 hw2
# Minqi Shi 111548035

class Array
    alias old_bracket []
    def [](i)
        element = '\0'
        actual = old_bracket(i)
        actual != nil ? (element = actual) : element
        element 
    end
end
