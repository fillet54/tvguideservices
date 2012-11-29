window.channel_number_width = "10%"

$(document).ready ->
   showGuide 2, 700

showGuide = (start, end) ->
   currentTime = get_time()
   drawTimeline(currentTime, 180, 30)
   drawChannels(currentTime, 180)

drawChannels = (startTime, duration) ->
   $.getJSON window.guide_url + "?callback=?", (data)->
      channels = new Array()
      $.each data, (i, program) ->
         ch = channels[program.channel]
         if typeof ch == 'undefined' 
            channels[program.channel] = new Array()
         channels[program.channel].push program
      add_channels(channels, startTime, duration)

get_time = ->
   now = new Date()
   now.getMinutes() + now.getHours() * 60

add_channels = (channels, startTime, duration) ->
   for channel in channels
      if typeof channel != 'undefined'
         add_channel channel

add_channel = (channel) ->
   $('#guide_data').append("<h1>Channel "+channel[0].channel+" Added with "+channel.length)


guide_width = ->
   return $('#container').width() - window.channel_number_width

drawTimeline = (startTime, duration, interval) ->
   timeline = $('#timeline')
   timeline.html("");
   timeline.append(channel_spacer())

   time = round_to_nearest_half_hour startTime
   for i in [1..duration/interval]
      timeString = minutes_to_hhmm time 
      time = round_minutes_in_day (time + interval)
      time = round_to_nearest_half_hour time
      width = "" + 90 / (duration/interval) + "%" 
      timeline.append(time_segment(timeString, width))

round_to_nearest_half_hour = (minutes) ->
   Math.floor(minutes / 30) * 30

round_minutes_in_day = (minutes) ->
   minutes_in_day = 60 * 24
   minutes = minutes - minutes_in_day if minutes >= minutes_in_day
   minutes

minutes_to_hhmm = (time_in_minutes) ->
   hours = Math.floor(time_in_minutes / 60)
   minutes = time_in_minutes % 60
   meridian = "am"
   meridian = "pm" if hours >= 12
   hours = hours - 12 if hours > 12
   hours = 12 if hours == 0
   minutes = "0" + minutes if minutes < 10
   hhmm = hours + ":" + minutes + meridian

time_segment = (time, width) ->
   segment = $('<span></span>)')
   segment.text(time)
   segment.attr('class', 'segment')
   segment.width(width)
   return segment

channel_spacer = ->
   spacer = $('<span></span>')
   spacer.width(window.channel_number_width);
   return spacer
   
   
   
