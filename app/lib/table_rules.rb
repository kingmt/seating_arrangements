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

  # given a list of seats and a person to add
  # attempt to place the new seat
  # returns a new list of seats if successful
  # returns nil if unsuccessful
  def autoplace seats, new_peep
    # brute force, naive implementation
    new_seat = Seat.new table: (seats.first.table), person: new_peep
    result = seats.each_index do |index|
               new_list = seats.dup
               new_list.insert index, new_seat
               if check_table(new_list).empty?
                 break new_list
               end
             end
    if result == seats
      nil
    else
      result
    end
  end

  # given a list of seats and which one to delete
  # returns true if the seat can be deleted leaving a valid table
  def can_be_unseated seats, to_be_unseated
    new_list = seats.dup
    new_list.delete to_be_unseated
    check_table(new_list).empty?
  end
end
