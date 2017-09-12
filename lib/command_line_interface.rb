require 'unirest'

$p1 = ""
match_up = []

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
  $p1 = gets.chomp
end

def player_one
  $p1_inst = Bettor.create(:name => $p1)
end


def find_team(team)
  team_data.body.find do |team_ob|
    team_ob["title"] == team
  end
end

def random_team
  team_data.body[rand(0..222)]
end

def match
  team_1 = random_team
  team_2 = random_team
  puts "The following are the available games to bet on:"
  puts "#{team_1["title"]} vs. #{team_2["title"]}"
  puts "Enter the name of the tean you are placing your bet on."
  team = gets.chomp
  tid = find_team(team)["id"]
  Bet.create(:bettor_id => $p1_inst[:id], :team_id => tid)
  array = [team_1["id"], team_2["id"]]
  winner = array.sample

  binding.pry
  if winner == tid
    puts "It Works"
  else
    puts "You lose"
  end
end
