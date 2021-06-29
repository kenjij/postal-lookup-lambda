require 'json'

def lambda_handler(event:, context:)
  ret = {ok: false, message: 'No results.'}
  # determine event source
  if event['routeKey']
    # API Gateway
    "GW!"
  else
    # internal
    # {"codes"=>["US12345", "US67890"]}
    codes = event['codes']
    case codes.length
    when 1
      one = lookup(codes[0])
      one ? ret = {ok: true, results: [one]} : (return ret)
      if (event['lat'] && event['lon'])
        if d = distance([one[:lat],one[:lon],event['lat'],event['lon']])
          puts "Distance is #{(d * 0.000621371).round}mi."
          ret[:results] << {lat: event['lat'], lon: event['lon']}
          ret[:distance] = d
        else
          ret[:message] = 'Bad coordinates.'
        end
      end
    when 2
      one = lookup(codes[0])
      one ? ret = {ok: true, results: [one]} : (return ret)
      two = lookup(codes[1])
      if two
        ret[:results] << two
        if d = distance([one[:lat],one[:lon],two[:lat],two[:lon]])
          puts "Distance is #{(d * 0.000621371).round}mi."
          ret[:distance] = d
        else
          ret[:message] = "Could not calculate distance."
        end
      else
        ret[:message] = 'No result for second postal code.'
      end
    else
      ret[:message] = 'Bad input.'
    end
  end
  ret
end

# @param code [String] in the form of <2-letter-cc><postal-code>
def lookup(code)
  country = DB[code[0..1]]
  return nil if country.nil?
  data = country[code[2..-1]]
  data ? data[:code] = code : data = nil
  data
end

# @param locs [Array] in the form of <lat1>,<lon1>,<lat2>,<lon2>
def distance(locs)
  return nil if locs.length != 4
  rad_pd = Math::PI/180  # Radian per degree
  r = 6371000    # Earth radius in meters
  dlat_rad = (locs[2]-locs[0]) * rad_pd
  dlon_rad = (locs[3]-locs[1]) * rad_pd
  lat1_rad = locs[0] * rad_pd
  lat2_rad = locs[2] * rad_pd
  a = Math.sin(dlat_rad / 2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad / 2)**2
  c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1 - a))
  (r * c).round
rescue => e
  puts "Distance calculation error: #{e}"
  nil
end

def import
  database = {}
  path = File.expand_path('../datasets', __FILE__)
  Dir.chdir(path) do
    Dir.foreach('.') do |f|
      next if File.directory?(f)
      IO.foreach(f) do |l|
        a = l.split("\t")
        next if a.nil?
        database[a[0]] ||= {}
        database[a[0]][a[1]] = {
          name: a[2],
          state: a[4],
          lat: a[9].to_f,
          lon: a[10].to_f,
        }
      end
    end
  end
  database
end

DB = import
DB.each do |k, v|
  puts "Imported cc: #{k}, records: #{v.length}"
end
