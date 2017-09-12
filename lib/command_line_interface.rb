require 'unirest'

def team_data
  response = Unirest.get "https://montanaflynn-fifa-world-cup.p.mashape.com/teams",
    headers:{
      "X-Mashape-Key" => "AYyq4yYeJLmshQdu0EvhtNVYVBRep1FSgP6jsnraZ5TInHi5VH",
      "accepts" => "json",
      "Accept" => "application/json"
    }
end

# puts response.body[rand(0..222)]["title"]


def welcome
  puts "Welcome! Let's bet on some World Cup matches!"
end

def menu
  puts "The following are the available games to bet on:"
  5.times do
    puts "#{team_data.body[rand(0..222)]["title"]} vs. #{team_data.body[rand(0..222)]["title"]}"
  end 
end

def select_team
  puts "Please select a team to place a bet on"
  gets.chomp
end
