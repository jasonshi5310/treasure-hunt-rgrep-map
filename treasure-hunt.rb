require 'set'

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
                # if room.is_safe == NOT_SAFE
                #     isSafe = false
                #     break
                # end
                if room.bats == true or room.pit == true or room.guard == true
                    isSafe =false
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


class Cave
    def initialize()
        @rooms = Array.new
        (1..20).each {|i| @rooms.push(Room.new(i))}
    end

    attr_accessor :rooms

    def room(i)
        if (1..20).include? i
            @rooms[i-1]
        end
    end

    def self.dodecahedron
        cave = Cave.new
        #outer
        cave.room(1).connect(cave.room(2))
        cave.room(8).connect(cave.room(7))
        cave.room(10).connect(cave.room(9))
        cave.room(10).connect(cave.room(2))
        cave.room(2).connect(cave.room(3))
        cave.room(8).connect(cave.room(11))
        cave.room(11).connect(cave.room(20))
        cave.room(11).connect(cave.room(10))
        cave.room(1).connect(cave.room(5))
        cave.room(1).connect(cave.room(8))
        # middle
        cave.room(3).connect(cave.room(12))
        cave.room(5).connect(cave.room(6))
        cave.room(6).connect(cave.room(15))
        cave.room(3).connect(cave.room(4))
        cave.room(4).connect(cave.room(14))
        cave.room(4).connect(cave.room(5))
        cave.room(6).connect(cave.room(7))
        cave.room(7).connect(cave.room(17))
        cave.room(19).connect(cave.room(9))
        cave.room(9).connect(cave.room(12))
        cave.room(17).connect(cave.room(16))
        cave.room(17).connect(cave.room(20))
        cave.room(20).connect(cave.room(19))
        cave.room(19).connect(cave.room(18))
        cave.room(12).connect(cave.room(13))
        # inner
        cave.room(14).connect(cave.room(15))
        cave.room(15).connect(cave.room(16))
        cave.room(16).connect(cave.room(18))
        cave.room(13).connect(cave.room(14))
        cave.room(13).connect(cave.room(18))
        cave
    end

    def random_room
        random_index = Random.new.rand(@rooms.count)
        @rooms[random_index]
    end

    def move(hazard, room, new_room)
        if hazard.instance_of?(Symbol) and room.instance_of?(Room) and new_room.instance_of?(Room)
            if hazard == :guard
                if room.guard == true and new_room.guard == false
                    room.guard = false
                    new_room.guard = true
                end
            elsif hazard == :pit
                if room.pit == true and new_room.pit == false
                    room.pit = false
                    new_room.pit = true
                end
            elsif hazard == :bats
                if room.bats == true and new_room.bats == false
                    room.bats = false
                    new_room.bats = true
                end
            else
                false
            end
        end
    end

    def add_hazard(hazard, count)
        if hazard.instance_of?(Symbol) and count.instance_of?(Integer) and count>0
            (1..count).each do |i|
                room = self.random_room
                if hazard == :guard
                    if room.guard == true
                        redo
                    else
                        room.add(hazard)
                    end
                elsif hazard == :pit
                    if room.pit == true
                        redo
                    else
                        room.add(hazard)
                    end
                elsif hazard == :bats
                    if room.bats == true
                        redo
                    else
                        room.add(hazard)
                    end
                else
                    false
                    break
                end
            end
        end
    end

    def room_with(hazard)
        if hazard.instance_of?(Symbol)
            @rooms.select {|r| r.has?(hazard)} [0]
        end
    end

    def entrance
        @rooms.select {|r| r.safe?} [0]
    end
end

class Player
    def initialize
        @room = nil
        @sense_hash = {}
        @encounter_hash = {}
        @action_hash = {}
    end

    attr_accessor :room

    def enter(r)
        if r.instance_of?(Room)
            @room = r
        end
    end

    def sense(hazard, &block)
        #@sense_hash.store(hazard, &block)
        @sense_hash[hazard] = block
    end

    def encounter(hazard, &block)
        @encounter_hash.store(hazard, block)
    end

    def action(hazard, &block)
        @action_hash.store(hazard, block)
    end

    def explore_room
        # encountered something
        if @room.bats != false
            @encounter_hash[:bats].call
        elsif @room.pit != false
            @encounter_hash[:pit].call
        elsif @room.guard != false
            @encounter_hash[:guard].call
        elsif @room.safe? == false
            # sensed something
            sensed = Set.new
            @room.neighbors.each {|r|
                if r.safe? == true
                    next
                end
                if r.bats == true
                    sensed.add(:bats)
                end
                if r.guard == true
                    sensed.add(:guard)
                end
                if r.pit == true
                    sensed.add(:pit)
                end
            }
            if sensed.empty? != true
                sensed.each {|hazard| @sense_hash[hazard].call}
            end
        end
    end

    def act(action_symbol, room)
        if action_symbol.instance_of?(Symbol) and room.instance_of?(Room)
            @action_hash[action_symbol].call(room)
        end
    end
end
