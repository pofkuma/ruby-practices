nums = (1..20)

nums.each do |num|
  word = ""
  word << "Fizz" if (num % 3).zero?
  word << "Buzz" if (num % 5).zero?
  puts (word == "" ? num : word)
end
