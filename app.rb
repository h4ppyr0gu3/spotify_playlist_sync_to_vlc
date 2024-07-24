#! /usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/inline'

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

def login
  RSpotify.authenticate(
    ENV.fetch('SPOTIFY_CLIENT_ID'),
    ENV.fetch('SPOTIFY_CLIENT_SECRET')
  )

  # me = RSpotify::User.find(ENV.fetch('SPOTIFY_USER_ID'))
end

def song_path(track)
  fix_filename(track[:artists][0]) + ' - ' + fix_filename(track[:name]) + '.ogg'
end

def fix_filename(name)
  name.to_s.gsub(/[\/\\:|<>"?*\x00-\x1f]|^(AUX|COM[1-9]|CON|LPT[1-9]|NUL|PRN)(?![^.])|^\s|[\s.]$/i, "_")
end

# Function to create XPF playlist
def create_sxpf_playlist(playlist, tracks, output_file)
  android_path = "file:///storage/emulated/0/Music/Liked Songs/"
  computer_path = "file:///home/david/Music/Liked Music/"
  builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
    xml.playlist(version: "1", xmlns: "http://xspf.org/ns/0/") do
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

login

ENV.fetch('SPOTIFY_PLAYLIST_IDS').split(',').each do |playlist_id|
  playlist = RSpotify::Playlist.find(ENV.fetch('SPOTIFY_USER_ID'), playlist_id)
  all_tracks = get_all_tracks(playlist)
  playlist_file_name = playlist.name.downcase.gsub(' ', '_') + '.xspf'
  output_file_path = ENV.fetch('OUTPUT_DIR', '.') + '/' + playlist_file_name
  create_sxpf_playlist(playlist, all_tracks, output_file_path)
end

