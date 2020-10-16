# Inplementation of grep in Ruby
# Minqi Shi

MISSING_REQUIRED_ARGUMENTS = 'Missing required arguments'
# NO_SUCH_FILE_OR_DIRECTORY = 'No such file or directory'
INVALID_OPTION = 'Invalid option'
INVALID_COMBINATION_OF_OPTIONS = 'Invalid combination of options'

class NoFileError<StandardError
    def msg()
        MISSING_REQUIRED_ARGUMENTS
    end
end

class InvalidOptionError<StandardError
    def msg()
        INVALID_OPTION
    end
end

class InvalidCombinationError<StandardError
    def msg()
        INVALID_COMBINATION_OF_OPTIONS
    end
end


puts 'ARGV:'
for argument in ARGV
    puts argument
end
puts '-----------------------------------------'

if ARGV.length() < 2
    puts MISSING_REQUIRED_ARGUMENTS
    exit(1)
end

if ARGV.length() > 4
    puts INVALID_COMBINATION_OF_OPTIONS
    exit(1)
end

begin
    args = ARGV[1..-1]
    filename = ARGV[0]
    raise NoFileError if !File.file?(filename)
    for a in args[0..-2]
        if a.length() != 2
            raise InvalidOptionError
        end
        dash = a[0]
        op = a[1]
        if dash != '-' or (op != 'w' and op != 'p' and op != 'v' and op != 'c' and op != 'm')
            raise InvalidOptionError
        end
    end
    if args.length() == 3
        if args[0] == '-c'
            if args[1] == '-c' or args[1] == '-m'
                raise InvalidCombinationError
            end
        elsif args[1] == '-c'
            if args[0] == '-m'
                raise InvalidCombinationError
            end
        elsif args[0] == '-m'
            if args[1] != '-w' and args[1] != '-p'
                raise InvalidCombinationError
            end
        elsif args[1] == '-m'
            if args[0] != '-w' and args[0] != '-p'
                raise InvalidCombinationError
            end
        else
            raise InvalidCombinationError
        end
    end
    option = '-p'
    if args.length() == 2
        if args[0] == '-c' or args[0] == '-m'
            option = option + args[0]
        else
            option = args[0]
        end 
    elsif args.length == 3
        if args[0] == '-c'
            option = args[1] + '-c'
        elsif args[1] == '-c'
            option = args[0] + '-c'
        elsif args[0] == '-m'
            option = args[1] + '-m'
        elsif args[1] == '-m'
            option = args[0] + '-m'
        end
    end
    regex = Regexp.new(args[-1])
    File.open(filename, "r") do |file|
        # puts 'File content:'
        # for line in file
        #     puts line
        # end
        # puts '-----------------------------------------'
        puts 'Options:'
        puts option
        puts '------------------------------------------'
        puts 'Result:'
        case option
        when '-p' then file.each_line {|line| puts line if line =~ regex}
            # file.each_line do |line|
            #     puts line
            # end
        when '-p-c' then
        when '-p-m' then
        when '-w' then
        when '-w-c' then
        when '-w-m' then
        when '-v' then
        when '-v-c' then
        else
            puts 'Something went wrong'
        end
    end
    # else
    #     raise NoFileError
    # end
rescue NoFileError => e
    puts e.msg
    exit(1)
rescue InvalidOptionError => e
    puts e.msg
    exit(1)
rescue InvalidCombinationError => e
    puts e.msg
    exit(1)
end

