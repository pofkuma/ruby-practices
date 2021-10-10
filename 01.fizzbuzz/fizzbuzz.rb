nums = (1..20)

nums.each do |num|
  word = ""
  word += "Fizz" if (num % 3) == 0
  word += "Buzz" if (num % 5) == 0
  puts (word == "" ? num : word)
end
