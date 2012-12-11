window.channel_number_width = "10%"

$(document).ready ->
   showGuide 2, 700

Date.prototype.format_to_hhmm = () ->
   hours = this.getHours()
   hours = 12 if hours == 0
   hours = hours - 12 if hours > 12
   minutes = this.getMinutes()
   minutes = "0" + minutes if minutes < 10
   am_pm = "am"
   am_pm = "pm" if this.getHours() >= 12
   hours + ":" + minutes + am_pm

Date.prototype.addMinutes = (minutes_to_add) ->
   this.setMinutes(this.getMinutes() + parseInt(minutes_to_add))
   this

Date.prototype.round_to_previous_half_hour = () ->
   this.setMinutes (Math.floor(this.getMinutes() / 30) * 30)
   this

showGuide = (start, end) ->
   currentTime = get_time()
   currentTime.round_to_previous_half_hour()
   drawTimeline(currentTime, 180, 30)
   drawChannels(currentTime, 180)

drawChannels = (startTime, duration) ->
   $.getJSON window.guide_url + "?callback=?", (data)->
      tempDraw(data, startTime, duration)

tempDraw = (data, startTime, duration) ->
   channels = new Array()
   add_datetime_to_results(data)
   $.each data, (i, program) ->
      ch = channels[program.channel]
      if typeof ch == 'undefined' 
         channels[program.channel] = new Array()
      channels[program.channel].push program
   $('#guide_data').append add_channels(channels, startTime, duration)

add_datetime_to_results = (data) ->
   $.each data, (i, program) ->
      month = program.startDate.substring(0, 2)
      day = program.startDate.substring(2, 4)
      hour = Math.floor(program.startTime / 60)
      year = "2012"
      minutes = program.startTime % 60
      seconds = 0
      date = new Date("" + month + "/" + day + "/" + year + " " + hour + ":" + minutes + ":" + seconds + " PST")
      program.start = date

get_time = ->
   now = new Date

add_channels = (channels, startTime, duration) ->
   channels_ul = $('<ul>')
   for channel in channels
      if typeof channel != 'undefined'
         channel_li = $('<li>')
         channel_li.append add_channel(channel, startTime, duration)
         channels_ul.append channel_li
   channels_ul

add_channel = (channel, startTime, duration) ->
   ch_div = $('<div>')
   ch_div.append channel_spacer(channel[0])
   for program in channel
      if program.start < startTime
         program.duration = program.duration - ((startTime - program.start) / 60000)
         program.start = startTime
         
      endTime = new Date(startTime).addMinutes(duration)
      program.endTime = new Date(program.start).addMinutes(program.duration) 

      if program.start < endTime
         if program.endTime > endTime 
            program.duration = program.duration - ((program.endTime - endTime) / 60000)
         program_el = add_program program
         program_el.width("" + Math.floor(90 / (duration/program.duration)) + "%")
         program_el.click () ->
            $.ajax window.remotecontrol_url  + program.channel

         ch_div.append program_el
   ch_div

add_program = (program) ->
   $('<span>').append(program.title)
  
drawTimeline = (startTime, duration, interval) ->
   timeline = $('#timeline').html("");
   timeline.append(timeline_spacer())

   width = "" + 90 / (duration/interval) + "%" 
   time = new Date(startTime)
   for i in [1..duration/interval]
      timeline.append time_segment(time.format_to_hhmm(), width)
      time.addMinutes interval

time_segment = (time, width) ->
   segment = $('<span></span>)')
   segment.text(time)
   segment.attr('class', 'segment')
   segment.width(width)
   return segment

timeline_spacer = ->
   spacer = $('<span></span>')
   spacer.width(window.channel_number_width);
   return spacer

channel_spacer = (channel) ->
   spacer = $('<span>')
   spacer.append(channel.channel)
   image = $('<img></img>')
   image.attr 'src', "images/logos/" + get_channel_logo(channel.callSign) 
   spacer.append(image)
   spacer.width(window.channel_number_width);
   return spacer

get_channel_logo = (call_sign) ->
   logo = if channel_map[call_sign] then channel_map[call_sign] else "directv.png"
   logo

channel_map = { 
   KCBSDT: 'CBS_hd.png',
   KNBCDT: 'NBC.png',
   KTLADT: 'CW%20Television%20Network.png',
   KABCDT: 'ABC_hd.png',
   KTTVDT: 'FOX_hd.png',
   KVCR:   'PBS.png'
}
