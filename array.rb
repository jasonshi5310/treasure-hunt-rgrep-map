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


# Test cases
# a = [1,2,34,5]
# a[1] = 2
# a[10] = '\0'
# a.map(2..4) { |i| i.to_f} = [34.0, 5.0]
# a.map { |i| i.to_f} = [1.0, 2.0, 34.0, 5.0]
# b = ["cat","bat","mat","sat"]
# b[-1] = "sat"
# b[5] = '\0'
# b.map(2..10) { |x| x[0].upcase + x[1,x.length] } = ["Mat", "Sat"]
# b.map(2..4) { |x| x[0].upcase + x[1,x.length] } = ["Mat", "Sat"]
# b.map(-3..-1) { |x| x[0].upcase + x[1,x.length] } = ["Bat", "Mat", “Sat”]
# b.map { |x| x[0].upcase + x[1,x.length] } = ["Cat", "Bat", "Mat", "Sat"]

a = [1,2,34,5]
a[1]
a[10]
a.map(2..4) { |i| i.to_f}
a.map { |i| i.to_f}
b = ["cat","bat","mat","sat"]
b[-1]
b[5]
b.map(2..10) { |x| x[0].upcase + x[1,x.length] }
b.map(2..4) { |x| x[0].upcase + x[1,x.length] }
b.map(-3..-1) { |x| x[0].upcase + x[1,x.length] }


