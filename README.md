# HackSoc Calendar API
## Usage
### `/ical`
Returns the HackSoc iCal calendar.

### `/events/<year>/<month>`
Gets a list of HackSoc calendar events for the given year and month. The month 
should be specified as an integer where 1 is January.

Returns an array of Event objects.

### `/events/<year>/<month>/calendar`
Gets the HackSoc calendar events for the given year and month, arranged as a
2D array which can be copied into a calendar. The month should be specified as
an integer where 1 is January.

Returns a 2D array, with up to six rows and always seven
columns, of JSON objects with these keys:

  - `date` - Date this cell represents in the format `YYYY/MM/DD`
  - `day` - Day of the date this cell represents
  - `in_month` - Whether this cell is part of the requested month
  - `events` - The events on this date

The 2D array's structure matches that of a calendar. The array, called `x` here,
may be organised into a calendar like so. Remember that `x[0][0]` is unlikely to
be the first day of the requested month.

| Mon       | Tue       | Wed       | Thu       | Fri       | Sat       | Sun       |
|-----------|-----------|-----------|-----------|-----------|-----------|-----------|
| `x[0][0]` | `x[0][1]` | `x[0][2]` | `x[0][3]` | `x[0][4]` | `x[0][5]` | `x[0][6]` |
| `x[1][0]` | `x[1][1]` | `x[1][2]` | `x[1][3]` | `x[1][4]` | `x[1][5]` | `x[1][6]` |
| And so on... |

The calendar has as many rows as required to show the entire month. There will
never be rows entirely not part of the requested month.

### Event object

Event objects have these keys:

  - `summary` - The event's title
  - `description` - The event's description
  - `location` - The event's location
  - `when_raw` - A JSON object with...
    - `start` - The event's ISO8601 start date
    - `end` - The event's ISO8601 end date
  - `when_human` - A JSON object with...
    - `start_time` - The event's start time, in the format HH:MM
    - `end_time` - The event's end time, in the format HH:MM
    - `short_start_date` - The event's start date, in the format `DD/MM/YYYY`
    - `short_end_date` - The event's end date, in the format `DD/MM/YYYY`
    - `long_start_date` - The event's start date, in a format like `Monday 1 January 2019`
    - `long_end_date` - The event's end date, in the format like `Monday 1 January 2019`

## Deployment

For host 0.0.0.0, port 9000, production mode, in a terminal:

```
gem install bundler
bundle install
bundle exec main.rb -p 9000 -e production
```

Swapping `production` for `development` will enable stack traces and host on `localhost` instead of `0.0.0.0`.