require 'unirest'

def team_data
  response = Unirest.get "https://montanaflynn-fifa-world-cup.p.mashape.com/teams",
    headers:{
      "X-Mashape-Key" => "AYyq4yYeJLmshQdu0EvhtNVYVBRep1FSgP6jsnraZ5TInHi5VH",
      "accepts" => "json",
      "Accept" => "application/json"
    }
end

def create_teams
  i = 0
  while i < 222
    Team.create(:name => team_data.body[i]["title"])
    i += 1
  end
end

def welcome
  puts "Welcome! What is your full name?"
  full_name = gets.chomp
  bettors.create(:name => full_name, :tokens => 20)
end

def menu
  puts "The following are the available games to bet on:"
  puts "#{team_data.body[rand(0..222)]["title"]} vs. #{team_data.body[rand(0..222)]["title"]}"
end

def select_team
  puts "Please select a team to place a bet on"
  gets.chomp
end
