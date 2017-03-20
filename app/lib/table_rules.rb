# built as a module since the logic doesn't truely belong
# in the models

module TableRules
  extend self

  # receives an array of seats
  # returns an array of errors
  def check_table seats
    errors = []
    seats.each_with_index do |seat, index|
      left = one_left seats, index
      right = one_right seats, index
      errors << SeatingRules.check_all_rules(left.person, seat.person, right.person)
    end
    errors.flatten.compact
  end

  # given an array of seats, the existing seat, and desired location
  # attempt to move the new seat
  # returns a new list of seats if successful and updates the table
  # returns nil if unsuccessful
  def move! seats, existing_seat, new_position
    new_list = seats.dup
    new_list.delete existing_seat
    new_list.insert new_position - 1, existing_seat
    if check_table(new_list).empty?
      # since acts_as_list is 1 indexed need index + 1
      existing_seat.position = new_position
      existing_seat.save
      new_list
    else
      nil
    end
  end

  # returns the element one to the left
  # of the index following the ring
  def one_left arr, index
    arr[index-1]
  end

  # returns the element two to the left
  # of the index following the ring
  def two_left arr, index
    arr[index-2]
  end

  # returns the element one to the right
  # of the index following the ring
  def one_right arr, index
    if arr.size == index + 1
      arr[0]
    else
      arr[index+1]
    end
  end

  # returns the element two to the right
  # of the index following the ring
  def two_right arr, index
    if arr.size == index + 2
      arr[0]
    elsif arr.size == index + 1
      arr[1]
    else
      arr[index+1]
    end
  end

  # given an array of seats, the person to add, and a position
  # attempt to place the new seat
  # returns true if successful and updates the table
  # returns nil if unsuccessful
  # because the way the insert works what is right one to
  # the position is actually the index
  def place! seats, new_seat, position
    if position > seats.size
      index = 0
    else
      index = position - 1
    end
    l2 = two_left(seats, index).person
    l1 = one_left(seats, index).person
    r1 = seats[index].person
    r2 = one_right(seats, index).person
    new_peep = new_seat.person
    if SeatingRules.check_all_rules(l2, l1, new_peep).empty? &&
       SeatingRules.check_all_rules(l1, new_peep, r1).empty? &&
       SeatingRules.check_all_rules(new_peep, r1, r2).empty?
      # valid placement
      new_seat.position = position
      new_seat.save
      true
    else
      nil
    end
  end

  # given an array of seats and a person to add
  # attempt to place the new seat
  # returns true if successful and updates the table
  # returns nil if unsuccessful
  def autoplace! seats, new_peep
    new_seat = Seat.new table: (seats.first.table), person: new_peep
    result = seats.each_index do |index|
               # 0 index vs 1 index
               position = index + 1
               if place!(seats, new_seat, position)
                 break :placed
               end
             end
    if result == :placed
      true
    else
      nil
    end
  end

  # given an array of seats and which one to check
  # returns true if the seat can be deleted leaving a valid table
  def can_be_unseated seats, to_be_unseated
    # special cases
    if seats.size <= 2
      true
    elsif seats.size == 3
      # in order to remove 1 the 2 remaining must have the same age
      index = seats.index(to_be_unseated)
      l1 = one_left(seats, index).person
      r1 = one_right(seats, index).person
      r1.age == l1.age
    else
      # assume [x, x, l2, l1, tbd, r1, r2, x, x] if tbd is removed
      # then the list [x, x, l2, l1, r1, r2, x, x] must be valid
      # the x locations do not need to be checked only the l and r
      # locations matter
      index = seats.index(to_be_unseated)
      l2 = two_left(seats, index).person
      l1 = one_left(seats, index).person
      r1 = one_right(seats, index).person
      r2 = two_right(seats, index).person
      SeatingRules.check_all_rules(l2, l1, r1).empty? &&
      SeatingRules.check_all_rules(l1, r1, r2).empty?
    end
  end
end
