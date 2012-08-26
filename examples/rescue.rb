# Slightly silly example written for http://cirw.in/blog/pry-to-the-rescue
# (NOTE: the solution in the blog post only works on ruby-1.9)
def find_capitalized(a)
  a.select do |name|
    name.chars.first == name.chars.first.upcase
  end
end

def extract_people(opts)
  name_keys = find_capitalized(opts.keys)

  name_keys.each_with_object({}) do |name, o|
    o[name] = opts.delete name
  end
end

def perform_moves(opts)
  people = extract_people(opts)

  people.each do |(first, last)|
    puts "#{first} #{last} moves #{opts[:direction]}"
  end
end

perform_moves("Arthur" => "Dent", :direction => :left)
