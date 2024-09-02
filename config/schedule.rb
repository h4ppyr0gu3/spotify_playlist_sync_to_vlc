# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
#
every 1.minute do
  command ". $HOME/.asdf/asdf.sh && /home/david/.asdf/shims/ruby /usr/local/bin/spotify_to_vlc -u 31whpm5krwcqauctazr2q6cyuwbu -s 7d258f88c8504671afae3daa0b4c1dc2 -i be46642fac0349e5be8701a3334f531b -p 3PkpP9NiY375g8wEx6ku7r,5SpDRqWjaGu7akzXJWSARu,4LlKG5tStLLUEQkOjvV9fC,2rX83BkoF3koFmedoUDs3J,7AMTTWYINFmWSwVRCmzo7G,134jLTtO7IgczbqjVEvSEB,66Qen9GZ1uDHYFfVzWQJzc,1sRiEecMJj2qbhPj805JkL -o /home/david/Music -v >> $HOME/.spotify_cron_log 2>&1"
end
