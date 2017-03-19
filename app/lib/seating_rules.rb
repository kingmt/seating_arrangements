# built as a module since the logic doesn't truely belong
# in the models

module SeatingRules
  extend self

  # encapsulate all rules, callers don't need to know
  # all the rules and makes it much easier to add/remove
  # rules in the future
  def check_all_rules left, center, right
    errors = []
    errors << check_within_5(left, center, right)
    errors << check_valley(left, center, right)
    errors.flatten.compact
  end

  # receives 3 people records
  # return and array of errors, empty array means
  # the rule passed
  def check_within_5 left, center, right
    errors = []
    errors << check_within_x(left, center, 5)
    errors << check_within_x(right, center, 5)
    errors.compact
  end

  # DRY up check_within checks
  def check_within_x p1, p2, x
    if (p1.age - p2.age).abs > x
      "The age difference between #{p1.name} and #{p2.name} is greater than #{x}"
    else
      nil
    end
  end

  # receives 3 people records
  # returns an error string or nil
  # QUESTION if there are only 2 people at the table, so left and
  #          right are the same person can there be a valley?
  def check_valley left, center, right
    if left.age > center.age && center.age < right.age
      "#{center.name} is younger than both #{left.name} and #{right.name}"
    else
      nil
    end
  end
end
