class Console
  def initialize(player, narrator)
    @player   = player
    @narrator = narrator
  end

  def show_room_description
    @narrator.say "-----------------------------------------"
    @narrator.say "You are in room #{@player.room.number}."

    @player.explore_room

    @narrator.say "Exits go to: #{@player.room.exits.join(', ')}"
  end

  def ask_player_to_act
    actions = {"m" => :move, "s" => :shoot, "i" => :inspect }

    accepting_player_input do |command, room_number|
      @player.act(actions[command], @player.room.neighbor(room_number))
    end
  end

  private

  def accepting_player_input
    @narrator.say "-----------------------------------------"
    command = @narrator.ask("What do you want to do? (m)ove or (s)hoot?")

    unless ["m","s"].include?(command)
      @narrator.say "INVALID ACTION! TRY AGAIN!"
      return
    end

    dest = @narrator.ask("Where?").to_i

    unless @player.room.exits.include?(dest)
      @narrator.say "THERE IS NO PATH TO THAT ROOM! TRY AGAIN!"
      return
    end

    yield(command, dest)
  end
end

class Narrator
  def say(message)
    $stdout.puts message
  end

  def ask(question)
    print "#{question} "
    $stdin.gets.chomp
  end

  def tell_story
    yield until finished?

    say "-----------------------------------------"
    describe_ending
  end

  def finish_story(message)
    @ending_message = message
  end

  def finished?
    !!@ending_message
  end

  def describe_ending
    say @ending_message
  end
end


# -------------------------------------------------------------

SAFE = 0 # 'safe'
# BATS = 1
# NEIGHBORS_BATS = 2
# PIT = 2
# GUARD = 3
# NEIGHBORS_GUARD = 4
NOT_SAFE = 5

class Room
    def initialize(number, guard=false, bats=false, pit=false, neighbors=Array.new, is_safe = SAFE)
        @number = number
        @guard = guard
        @bats = bats
        @pit = pit
        @neighbors = neighbors
        @is_safe = is_safe
    end
    attr_accessor :number, :bats, :guard, :pit, :neighbors, :is_safe

    def empty?
        @is_safe == SAFE
    end

    def add(hazard)
        if hazard.instance_of?(Symbol)
            is_there = true
            if hazard == :guard
                @guard = true
            elsif hazard == :pit
                @pit = true
            elsif hazard == :bats
                @bats = true
            else
                is_there = false
            end
            # self.method(hazard).call
            if is_there
                @is_safe = NOT_SAFE
            end
        end
    end

    def remove(hazard)
        if hazard.instance_of?(Symbol)
            # self.method(hazard).call
            if hazard == :guard
                @guard = false
            elsif hazard == :pit
                @pit = false
            elsif hazard == :bats
                @bats = false
            end
            if @guard == false and @pit == false and @bats == false
                @is_safe = SAFE
            end
        end
    end

    def has?(hazard)
        if hazard.instance_of?(Symbol)
            if hazard == :guard
                @guard
            elsif hazard == :pit
                @pit
            elsif hazard == :bats
                @bats
            else
                false
            end
        else
            false
        end
    end

    def connect(room)
        if room.instance_of?(Room)
            @neighbors.push(room)
            room.neighbors.push(self)
        end
    end

    def exits
        @neighbors.collect {|room| room.number}
    end

    def random_neighbor
        random_index = Random.new.rand(@neighbors.length())
        @neighbors[random_index]
    end

    def safe?
        if @is_safe == NOT_SAFE
            false
        else
            isSafe = true
            for room in neighbors
                if room.is_safe == NOT_SAFE
                    isSafe = false
                    break
                end
            end
            isSafe
        end
    end

    def neighbor(i)
        @neighbors.select {|room| room.number == i} [0]
    end
end
