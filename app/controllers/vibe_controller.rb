require 'uri'

class VibeController < ApplicationController

  def show
    query_string = "https://developer.echonest.com/api/v4/playlist/basic?api_key="
    query_string += ENV["Echonest_Key"]
    input_type = params[:input_type]
    input = params[:input]

    if input_type == "song"
      # Search for song input
      song_query = "https://developer.echonest.com/api/v4/song/search?api_key="
      song_query += ENV["Echonest_Key"]
      song_query += "&title=" + input
      song_query += "&format=json"
      song_query = URI.escape(song_query)
      song = JSON.parse(HTTParty.get(song_query).body)

      if song["response"]["status"]["message"] != "Success"
        flash.alert = "Song not found"
        redirect_to root_path
        return
      end

      logger.info(song)
      query_string += "&song_id=" + song["response"]["songs"][0]["id"]
      query_string += "&format=json"
      query_string += "&type=song-radio"
      query_string = URI.escape(query_string)
      response = JSON.parse(HTTParty.get(query_string).body)

      if response["response"]["status"]["message"] != "Success"
        flash.alert = "Song not found"
        redirect_to root_path
        return
      end

      @results = response["response"]["songs"]
    elsif input_type == "genre"
      query_string += "&genre=" + input
      query_string += "&format=json"
      query_string += "&type=genre-radio"
      query_string = URI.escape(query_string)
      response = JSON.parse(HTTParty.get(query_string).body)

      if response["response"]["status"]["message"] != "Success"
        flash.alert = "Invalid genre"
        redirect_to root_path
        return
      end

      @results = response["response"]["songs"]
    else
      query_string += "&artist=" + input
      query_string += "&format=json"
      query_string += "&type=artist-radio"
      query_string = URI.escape(query_string)
      response = JSON.parse(HTTParty.get(query_string).body)

      if response["response"]["status"]["message"] != "Success"
        flash.alert = "Artist not found"
        redirect_to root_path
        return
      end

      @results = response["response"]["songs"]
    end

    @tracks = []
    @results.each do |r|
      search_query = "https://www.googleapis.com/youtube/v3/search?"
      search_query += "q=" + r["artist_name"] + "+" + r["title"]
      search_query += "&part=snippet"
      search_query += "&key=" + ENV['Google_Key']
      search_query = URI.escape(search_query)
      video_result = JSON.parse(HTTParty.get(search_query).body)

      @tracks.push(video_result["items"][0])
    end
  end

  logger.info(@tracks)

end
