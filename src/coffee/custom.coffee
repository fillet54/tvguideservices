window.channel_number_width = "10%"

$(document).ready ->
   showGuide 2, 700

showGuide = (start, end) ->
   drawTimeline("TIME", 180, 30)
   $.getJSON window.guide_url + "?callback=?", (data)->
      channels = new Array()
      $.each data, (i, program) ->
         ch = channels[program.channel]
         if typeof ch == 'undefined' 
            channels[program.channel] = new Array()
         channels[program.channel].push program
      add_channels(channels)

add_channels = (channels) ->
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

   for i in [1..duration/interval]
      time = "TIME " + i
      width = "" + 90 / (duration/interval) + "%" 
      timeline.append(time_segment(time, width))

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
   
   
   
