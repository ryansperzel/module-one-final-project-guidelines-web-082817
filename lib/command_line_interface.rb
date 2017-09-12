require 'unirest'
require 'colorize'
require 'colorized_string'

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
  puts "Welcome to the World Cup!\n\n
  ░░░░░░▄███████████▀▀▀█▄▄░░░░░░░░
░░░░▄██████████▀░░░░░░░▀▀██▄░░░░
░░▄█▀▀▀▀▀▀▀██▀░░░░░░░░░░░░███▄░░
▄█▀░░░░░░░░░█▄░░░░░░░░░░░░░████░
▀░░░░░░░░░░░░█▄░░░░░░░░░░░▄█████
▄▄░░░░░░░░░░░░▀█▄▄▄▄▄▄░▄█▀▀░░▀██
███░░░░░░░░░░░█████████▀░░░░░░░▀
███▄░░░░░░░░▄███████████░░░░░░░░
████▄▄▄▄▄▄▄█████████████░░░░░░░░
███▀░░░░░░░█████████████░░░░░░░░
███░░░░░░░░░▀██████████▀▀▄░░░░░█
░░░░░░░░░░░░░░██████▀▀░░░░▀▄░▄██
█▄░░░░░░░░░░░▄█░░░░░░░░░░░░▄██▀░
░▀█▄░░░░░░░░░█░░░░░░░░░░░░███▀░░
░░░▀▀█▄▄▄▄▄▄██░░░░░░░░░░░██▀░░░░
░░░░░░░▀▀██████▄▄░░░░░▄▄█▀░░░░░░
\n\n"


  puts "What is your name Player One?".colorize(:red)
  $p1 = gets.chomp

  puts "\n\n\n\nWhat is yout name Player Two".colorize(:blue)
  $p2 = gets.chomp

end

def players
  $p1_inst = Bettor.create(:name => $p1, :tokens => 20)
  $p2_inst = Bettor.create(:name => $p2, :tokens => 20)
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
  round_counter = 1

  while round_counter <= 5
    team_1 = random_team
    team_2 = random_team

    puts "\n\n\nThe following are the available games to bet on:\n\n\n"
    sleep(1)
    puts "#{team_1["title"]}\n\n"
    sleep(1)
    puts "vs."
    sleep(1)
    puts "\n\n#{team_2["title"]}"
    puts "\n\n\n#{$p1}: choose your team".colorize(:red)
    team = gets.chomp

    puts "\n\n\n#{$p2}: choose your team".colorize(:blue)
    team2 = gets.chomp

    tid = find_team(team)["id"]
    tid2 = find_team(team2)["id"]
    Bet.create(:bettor_id => $p1_inst[:id], :team_id => tid)
    Bet.create(:bettor_id => $p2_inst[:id], :team_id => tid2)
    array = [team_1["id"], team_2["id"]]
    winner = array.sample

    if winner == tid && winner == tid2
      puts "BOTH PLAYERS WON THE ROUND!"
    elsif winner == tid && winner != tid2
      puts "Player 1 won the round!".colorize(:red)
      sleep(3)
      $p2_inst.update(tokens:($p2_inst["tokens"]-10))
      if $p2_inst["tokens"] <= 0
        puts "PLAYER ONE WON THE GAME!".colorize(:red)
        break
      end
    elsif winner == tid2 && winner != tid
      puts "Player 2 won the round!".colorize(:blue)
      sleep(3)
      $p1_inst.update(tokens:($p1_inst["tokens"]-10))
      if $p1_inst["tokens"] <= 0
        puts "PLAYER TWO WON THE GAME!".colorize(:blue)
        break
      end
    else
      winner != tid && winner != tid2
      puts "BOTH PLAYERS LOST THE ROUND!"
      $p1_inst.update(tokens:($p1_inst["tokens"]-10))
      $p2_inst.update(tokens:($p2_inst["tokens"]-10))
    end
    total_score
    round_counter += 1
  end
end

def total_score
  puts "#{$p1} Total: #{$p1_inst[:tokens]}"
  puts "#{$p2} Total: #{$p2_inst[:tokens]}"
end
