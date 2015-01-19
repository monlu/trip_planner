require 'httparty'
require 'cgi'
require 'pry'
require 'date'
require 'colorize'

class TripPlanner
  attr_reader :user, :forecast, :recommendation, :forecast_info
  
  def initialize
    # Should be empty, you'll create and store @user, @forecast and @recommendation elsewhere
  end
  
  def start
    self.create_user
    self.retrieve_forecast
    self.create_recommendation
    
    puts "Hello #{self.user.name}! Here is your forecast and recommendations!".red
    puts ""
    self.recommendation.each do |index|
      index.each do |keys, data|
        if keys == :date
          puts "#{keys}".magenta + "   ::   ".yellow + "#{data}".green
        elsif keys == :clothes
          clothes_string ||= ""
          data.each do |clothes|
            clothes_string += "#{clothes}, "
          end
          clothes_string[-2] = ""
          puts "#{keys}".magenta + "   ::   ".yellow + clothes_string.cyan
        elsif keys == :accessory
          accessories_string ||= ""
          data.each do |accessory|
            accessories_string += "#{accessory}, "
          end
          accessories_string[-2] = ""
          puts "#{keys}".magenta + "   ::   ".yellow + accessories_string.cyan
        else
         puts "#{keys}".magenta + "   ::   ".yellow + "#{data}".blue
        end
      end
      puts " "
    end




    # Plan should call create_user, retrieve_forecast and create_recommendation 
    # After, you should display the recommendation, and provide an option to 
    # save it to disk.  There are two optional methods below that will keep this
    # method cleaner.
  end
  
  # def display_recommendation
  # end
  #
  # def save_recommendation
  # end
  
  def create_user
    puts "Whats your name?"
    name = gets.chomp
    puts "Where would you like to go?"
    destination = gets.chomp
    puts "How long would you like to stay?"
    duration = gets.chomp.to_i
    @user = User.new(name, destination, duration)
    # provide the interface asking for name, destination and duration
    # then, create and store the User object
  end
  
  def retrieve_forecast
    days = @user.duration
    units = "imperial" # you can change this to metric if you prefer
    options = "daily?q=#{CGI::escape(@user.destination)}&mode=json&units=#{units}&cnt=#{days}"
    url = "http://api.openweathermap.org/data/2.5/forecast/#{options}"
    forecast_info = HTTParty.get(url)["list"]
    forecast_array = forecast_info.map do |days|
      days.map do |key, record|
        if key == "dt"
          Time.at(record)
        else
          record
        end
      end
    end
    @forecast = forecast_array.map do |day|
      {date: day[0], min_temp: day[1]["min"], max_temp: day[1]["max"], condition: day[4][0]["main"]}
    end
    # use HTTParty.get to get the forecast, and then turn it into an array of
    # Weather objects... you  might want to institute the two methods below
    # so this doesn't get out of hand...
  end
  
  # def call_api
  # end
  #
  # def parse_result
  # end
  
  def create_recommendation
    # once you have the forecast, ask each Weather object for the appropriate
    # clothing and accessories, store the result in @recommendation.  You might
    # want to implement the two methods below to help you kee this method
    # smaller...
    @recommendation = @forecast.map do |day|
      weather = Weather.new(day[:min_temp].to_i,day[:max_temp].to_i,day[:condition])
      {date: day[:date], min_temp: day[:min_temp], max_temp: day[:max_temp], condition: day[:condition], clothes: weather.appropriate_clothing , accessory: weather.appropriate_accessories}
    end

  end

  # def collect_clothes
  # end
  #
  # def collect_accessories
  # end
end

#trip = TripPlanner.new
#trip.create_user
#trip.retrieve_forecast



class Weather
  attr_reader :min_temp, :max_temp, :condition
  
  # given any temp, we want to search CLOTHES for the hash
  # where min_temp <= temp and temp <= max_temp... then get
  # the recommendation for that temp.
  CLOTHES = [
    {
      min_temp: 0, max_temp: 32,
      recommendation: [
        "insulated parka", "long underwear", "fleece-lined jeans",
        "mittens", "knit hat", "chunky scarf"
      ]
    },
    {
      min_temp: 33, max_temp: 60,
      recommendation: [
        "light jacket", "regular underwear", "jeans", "long sleeves", "spanks", "snuggie"
      ]
    },
    {
      min_temp: 61, max_temp: 100,
      recommendation:[
      "shorts-shorts", "t-shirt", "sandals", "jeans with holes", "birthday suit"
      ]
    }
  ]

  ACCESSORIES = [
    {
      condition: "Rain",
      recommendation: [
        "galoshes", "umbrella"
      ]
    },
    {
      condition: "Clear",
      recommendation: [
        "sunglasses", "eyepatch"
      ]
    },
    {
      condition: "Snow",
      recommendation: [
        "snow boots"
      ]
    },
    {
      condition: "Clouds",
      recommendation: [
        "fake mustache", "vermillion tinted sunglasses"
      ]
    },
    {
      condition: "Thunderstorm",
      recommendation: [
        "flux capacitor", "delorean"
      ]
    }
  ]
  
  def initialize(min_temp=1, max_temp=31, condition = "rain")
    @min_temp = min_temp
    @max_temp = max_temp
    @condition = condition
    
  end
  
  def self.clothing_for(temp)
    # This is a class method, have it find the hash in CLOTHES so that the 
    # input temp is between min_temp and max_temp, and then return the 
    # recommendation.
    CLOTHES.find do |minmaxtemps|
      if temp >= minmaxtemps[:min_temp] && temp <= minmaxtemps[:max_temp]
        return minmaxtemps[:recommendation]
      end
    end
  end
  
  def self.accessories_for(condition)
    ACCESSORIES.find do |conditions|
      if conditions[:condition] == condition
        return conditions[:recommendation]
      end
    end
  end
  
  def appropriate_clothing
    # Use the results of Weather.clothing_for(@min_temp) and 
    # Weather.clothing_for(@max_temp) to make an array of appropriate
    # clothing for the weather object.
    # You should avoid making the same suggestion twice... think
    # about using .uniq here
    appropriate_clothes = [Weather.clothing_for(@min_temp),Weather.clothing_for(@max_temp)]
    appropriate_clothes.flatten.uniq.compact
  end
  
  def appropriate_accessories
    # Use the results of Weather.accessories_for(@condition) to make
    # an array of appropriate accessories for the weather object.
    # You should avoid making the same suggestion twice... think
    # about using .uniq here
    appropriate_accessory = Weather.accessories_for(@condition)
    appropriate_accessory
  end
end

class User
  attr_reader :name, :destination, :duration
  
  def initialize(name, destination, duration)
    @name = name
    @destination = destination
    @duration = duration
  end
end

trip = TripPlanner.new
trip.start

#Pry.start(binding)