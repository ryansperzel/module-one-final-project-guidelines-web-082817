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
  puts "Welcome to the World Cup!
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
░░░░░░░▀▀██████▄▄░░░░░▄▄█▀░░░░░░"
  puts "What is your name Player One?"
  $p1 = gets.chomp
  puts "What is yout name Player Two"
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
    puts "The following are the available games to bet on:"
    puts "#{team_1["title"]} vs. #{team_2["title"]}"
    puts "Enter the name of the tean you are placing your bet on Player One."
    team = gets.chomp
    puts "Enter the name of the tean you are placing your bet on Player Two."
    team2 = gets.chomp
    tid = find_team(team)["id"]
    tid2 = find_team(team2)["id"]
    Bet.create(:bettor_id => $p1_inst[:id], :team_id => tid)
    Bet.create(:bettor_id => $p2_inst[:id], :team_id => tid2)
    array = [team_1["id"], team_2["id"]]
    winner = array.sample

    if winner == tid
      puts "Player 1 won the round!"
    else
      $p1_inst.update(tokens:($p1_inst["tokens"]-20))
      if $p1_inst["tokens"] > 0
        puts "Player 1 lost the round"
      else
        puts "GAME OVER PLAYER ONE!"
        break
      end
    end

    if winner == tid2
      puts "Player 1 won the round!"
    else
      $p2_inst.update(tokens:($p2_inst["tokens"]-20))
      if $p2_inst["tokens"] > 0
        puts "Player 2 lost the round"
      else
        puts "GAME OVER PLAYER TWO!"
        break
      end
    end
    round_counter += 1
  end
end
