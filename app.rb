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
  opts.banner = 'Usage: ruby ./app.rb [options]'

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
end.parse!

spotify_client_id = (options[:client_id] || ENV['SPOTIFY_CLIENT_ID']).to_s
spotify_client_secret = (options[:client_secret] || ENV['SPOTIFY_CLIENT_SECRET']).to_s
playlist_ids = options[:playlist_ids] || ENV['SPOTIFY_PLAYLIST_IDS'].split(',')
user_id = (options[:user_id] || ENV['SPOTIFY_USER_ID']).to_s
output_dir = (options[:output_dir] || ENV['OUTPUT_DIR']).to_s

def login(spotify_client_id, spotify_client_secret)
  RSpotify.authenticate(spotify_client_id, spotify_client_secret)

  # me = RSpotify::User.find(ENV.fetch('SPOTIFY_USER_ID'))
end

def song_path(track)
  fix_filename(track[:artists][0]) + ' - ' + fix_filename(track[:name]) + '.ogg'
end

def fix_filename(name)
  name.to_s.gsub(%r{[/\\:|<>"?*\x00-\x1f]|^(AUX|COM[1-9]|CON|LPT[1-9]|NUL|PRN)(?![^.])|^\s|[\s.]$}i, '_')
end

# Function to create XPF playlist
def create_sxpf_playlist(playlist, tracks, output_file)
  android_path = 'file:///storage/emulated/0/Music/Liked Songs/'
  computer_path = 'file:///home/david/Music/Liked Music/'
  builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
    xml.playlist(version: '1', xmlns: 'http://xspf.org/ns/0/') do
      xml.title playlist.name
      xml.trackList do
        tracks.each do |track|
          xml.track do
            if ENV.fetch('COMPUTER', nil) == 'true'
              xml.location computer_path + song_path(track)
            else
              xml.location android_path + song_path(track)
            end
          end
        end
      end
    end
  end

  File.write(output_file, builder.to_xml)
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

def get_file_version(file_name)
  file_name.split('.').first.split('_').last.to_i
end

def clean_files_and_return_next_version(output_dir)
  playlist_files = Dir.glob("#{output_dir}/*.xspf")
  last_version = playlist_files.map { |file| get_file_version(file) }.max
  playlist_files.each { |file| File.delete(file) }

  if last_version.nil?
    1
  else
    last_version + 1
  end
end

login(spotify_client_id, spotify_client_secret)

next_version = clean_files_and_return_next_version(output_dir)

playlist_ids.each do |playlist_id|
  playlist = RSpotify::Playlist.find(user_id, playlist_id)
  all_tracks = get_all_tracks(playlist)
  playlist_file_name = "#{playlist.name.downcase.gsub(' ', '_')}_#{next_version}.xspf"
  output_file_path = output_dir + "/#{playlist_file_name}"
  create_sxpf_playlist(playlist, all_tracks, output_file_path)
end
