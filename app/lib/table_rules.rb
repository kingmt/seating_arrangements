# built as a module since the logic doesn't truely belong
# in the models

module TableRules
  extend self

  # receives an array of seats
  # returns an array of errors
  def check_table seats
    errors = []
    seats.each_with_index do |seat, index|
      left = if seat == seats.first
               seats.last
             else
               seats[index - 1]
             end
      right = if seat == seats.last
                seats.first
              else
                seats[index + 1]
              end
      errors << SeatingRules.check_all_rules(left.person, seat.person, right.person)
    end
    errors.flatten.compact
  end

  # FIXME brute force, naive implementation on all the following methods
  #
  # better solution would be to iterate through the list and
  # get the 2 elements to the right R1, R2
  # and the 2 elements to the left L1, L2 and then check the 2 combinations
  # SeatingRules.check_all_rules(L2, L1, R1)
  # SeatingRules.check_all_rules(L1, R1, R2)
  # if both are valid then it can be placed/deleted

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

  # given an array of seats, the person to add, and a position
  # attempt to place the new seat
  # returns a new list of seats if successful and updates the table
  # returns nil if unsuccessful
  def place! seats, new_peep, position
    new_seat = Seat.new table: (seats.first.table), person: new_peep
    new_list = seats.dup
    # position is 1 based, array is 0 based
    # array.insert inserts the new element BEFORE the index
    new_list.insert position - 1, new_seat
    if check_table(new_list).empty?
      # since acts_as_list is 1 indexed need index + 1
      new_seat.position = position
      new_seat.save
      new_list
    else
      nil
    end
  end

  # given an array of seats and a person to add
  # attempt to place the new seat
  # returns a new list of seats if successful and updates the table
  # returns nil if unsuccessful
  #
  # there would be some additional overhead by calling place!
  # but it would reduce some code duplication
  def autoplace! seats, new_peep
    new_seat = Seat.new table: (seats.first.table), person: new_peep
    result = seats.each_index do |index|
               new_list = seats.dup
               # array.insert inserts the new element BEFORE the index
               new_list.insert index, new_seat
               if check_table(new_list).empty?
                 # since acts_as_list is 1 indexed need index + 1
                 new_seat.position = index + 1
                 new_seat.save
                 break new_list
               end
             end
    if result == seats
      nil
    else
      result
    end
  end

  # given an array of seats and which one to check
  # returns true if the seat can be deleted leaving a valid table
  def can_be_unseated seats, to_be_unseated
    # special case
    if seats.size <= 2
      true
    else
      new_list = seats.dup
      new_list.delete to_be_unseated
      check_table(new_list).empty?
    end
  end
end
