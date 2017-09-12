# require 'unirest'
#
# response = Unirest.get "https://montanaflynn-fifa-world-cup.p.mashape.com/teams",
#   headers:{
#     "X-Mashape-Key" => "AYyq4yYeJLmshQdu0EvhtNVYVBRep1FSgP6jsnraZ5TInHi5VH",
#     "accepts" => "json",
#     "Accept" => "application/json"
#   }
#
# puts response.body[rand(0..222)]["title"]
