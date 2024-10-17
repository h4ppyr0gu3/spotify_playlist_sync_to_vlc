#! /usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/inline'
require 'optparse'

gemfile true do
  source 'https://rubygems.org'

  gem 'rspotify'
  gem 'nokogiri'
  gem 'pry'
  gem 'dotenv'
end

require 'net/http'
require 'json'
require 'dotenv/load'

options = {}
OptionParser.new do |opts|
  # opts.banner = 'Usage: ruby ./app.rb [options]'

  opts.on('-i', '--client-id CLIENT_ID', 'Spotify Client ID') do |client_id|
    options[:client_id] = client_id
  end

  opts.on('-s', '--client-secret CLIENT_SECRET', 'Spotify Client Secret') do |client_secret|
    options[:client_secret] = client_secret
  end

  opts.on('-u', '--user-id USER_ID', 'Spotify User ID') do |user_id|
    options[:user_id] = user_id
  end

  opts.on('-p', '--playlist-ids PLAYLIST_IDS', 'Spotify Playlist IDs, comma seperated string') do |playlist_ids|
    options[:playlist_ids] = playlist_ids.split(',')
  end

  opts.on('-o', '--output-dir OUTPUT_DIR', 'Output directory') do |output_dir|
    options[:output_dir] = output_dir
  end

  opts.on('-v', 'verbose') do
    options[:verbose] = true
  end
end.parse!

spotify_client_id = (options[:client_id] || ENV['SPOTIFY_CLIENT_ID']).to_s
spotify_client_secret = (options[:client_secret] || ENV['SPOTIFY_CLIENT_SECRET']).to_s
# playlist_ids = options[:playlist_ids] || ENV['SPOTIFY_PLAYLIST_IDS'].split(',')
playlist_ids = ["1GTHGPYu6PN94DiD9JzCAT"]
user_id = (options[:user_id] || ENV['SPOTIFY_USER_ID']).to_s
# output_dir = (options[:output_dir] || ENV['OUTPUT_DIR']).to_s
verbose = options[:verbose] || ENV['VERBOSE']

def login(spotify_client_id, spotify_client_secret)
  RSpotify.authenticate(spotify_client_id, spotify_client_secret)

  # me = RSpotify::User.find(ENV.fetch('SPOTIFY_USER_ID'))
end

def get_all_tracks(playlist)
  all_tracks = []
  total_tracks = playlist.total

  while all_tracks.length < total_tracks
    playlist.tracks(limit: 100, offset: all_tracks.length).each do |track|
      all_tracks << {
        name: track.name,
        artists: track.artists.map do |artist|
          artist.name
        end
      }
    end
  end

  all_tracks
end

login(spotify_client_id, spotify_client_secret)

playlist_ids.each do |playlist_id|
  playlist = RSpotify::Playlist.find(user_id, playlist_id)
  all_tracks = get_all_tracks(playlist)
  all_tracks.each do |track|
    binding.pry
  end
end

