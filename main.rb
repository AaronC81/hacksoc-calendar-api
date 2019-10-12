#!/usr/bin/env ruby
require 'icalendar'
require 'open-uri'
require 'active_support/all'
require 'sinatra'
require 'json'

ICAL_URL = 'https://calendar.google.com/calendar/ical/yusu.org_h8uou2ovt1c6gg87q5g758tsvs%40group.calendar.google.com/public/basic.ics'

def event_to_hash(event)
  {
    when_raw: {
      start: event.dtstart,
      end: event.dtend,
    },
    when_human: {
      start_time: event.dtstart.strftime('%H:%M'),
      end_time: event.dtend.strftime('%H:%M'),
      short_start_date: event.dtstart.strftime('%d/%m/%Y'),
      short_end_date: event.dtend.strftime('%d/%m/%Y'),
      long_start_date: event.dtstart.strftime('%A %-d %B %Y'),
      long_end_date: event.dtend.strftime('%A %-d %B %Y')
    },
    summary: event.summary,
    description: event.description,
    location: event.location
  }
end

def all_events
  calendar = Icalendar::Calendar.parse(open(ICAL_URL)).first
  calendar.events.map do |event|
    Time.zone = 'London'
    event.dtstart = event.dtstart.in_time_zone
    event.dtend = event.dtend.in_time_zone

    event
  end
end

def events_in_month(year, month)
  all_events
    .select { |e| e.dtstart.month == month && e.dtstart.year == year }
    .sort_by(&:dtstart)
end

before do
  content_type :json
  response.headers['Access-Control-Allow-Origin'] = '*'
end

get '/ical' do
  content_type 'text/calendar'
  open(ICAL_URL)
end

get '/events/:year/:month' do |year, month|
  halt 400, { error: 'provide numbers' }.to_json unless /^\d+$/ === year && /^\d+$/ === month

  events_in_month(year.to_i, month.to_i)
    .map { |e| event_to_hash(e) }
    .to_json
end

CALENDAR_ROWS = 6
DAYS_OF_WEEK = 7

get '/events/:year/:month/calendar' do |year, month|
  halt 400, { error: 'provide numbers' }.to_json unless /^\d+$/ === year && /^\d+$/ === month

  year = year.to_i
  month = month.to_i

  events = events_in_month(year, month)

  calendar_flat = Array.new(CALENDAR_ROWS * DAYS_OF_WEEK) { {} }

  first_date_of_month = Date.new(year, month, 1)
  commencing_date_of_first_week_of_calendar = first_date_of_month.at_beginning_of_week

  current_date = commencing_date_of_first_week_of_calendar
  (CALENDAR_ROWS * DAYS_OF_WEEK).times do |i|
    calendar_flat[i][:date] = current_date
    calendar_flat[i][:day] = current_date.day
    calendar_flat[i][:in_month] = (current_date.month == month)
    calendar_flat[i][:events] = events.select do |event|
      event.dtstart.year == year && event.dtstart.month == month && event.dtstart.day == current_date.day
    end.map { |event| event_to_hash(event) }
    
    current_date = current_date.succ
  end

  calendar_flat.in_groups_of(DAYS_OF_WEEK).reject { |r| r.none? { |c| c[:in_month] } }.to_json
end
