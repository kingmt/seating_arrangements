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

  # given an array of seats and a person to add
  # attempt to place the new seat
  # returns a new list of seats if successful and updates the table
  # returns nil if unsuccessful
  # FIXME brute force, naive implementation
  # better solution would be to iterate through the list and
  # get the 2 elements to the right R1, R2
  # and the 2 elements to the left L1, L2 and then check the 2 combinations
  # SeatingRules.check_all_rules(L2, L1, R1)
  # SeatingRules.check_all_rules(L1, R1, R2)
  # if both are valid then it can be deleted
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
  # FIXME brute force naive solution
  # better solution would be to get the 2 elements to the right R1, R2
  # and the 2 elements to the left L1, L2 and then check the 2 combinations
  # SeatingRules.check_all_rules(L2, L1, R1)
  # SeatingRules.check_all_rules(L1, R1, R2)
  # if both are valid then it can be deleted
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
