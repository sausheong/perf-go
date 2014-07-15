require 'gruff'
require 'json'

NUM_POINTS = {100 => 1, 50 => 20, 25 => 40, 20 => 25, 10 => 100}
COLOR = ["#ff0000", "#00ff00", "#0000ff", "#ffff00", "#00ff", "#ff00ff"]
def process(chart, metric)
  d = {}
  chart.each do |k, v|
    d[k.to_i] = v[metric].to_f
  end
  d.delete_if do |k, v|
    k % NUM_POINTS[100] != 0
  end
  
  return d
end

json_array = []
names = []
Dir["*.json"].each_with_index do |file, i|
  json_array[i] = JSON.parse(File.read(file))   
  names[i] = file.split(".").first
end


metrics = ["connection_rate_per_sec", "connection_time_avg", "total_test_duration", "reply_status_2xx"]


metrics.each do |metric|
  processed_json = []
  json_array.each_with_index do |array, i|
    processed_json[i] = process(array, metric)
  end
  
  labels = {}
  processed_json.first.keys.size.times do |i|
    labels[i] = processed_json.first.keys[i].to_s
  end

  chart = Gruff::Line.new(1024)
  chart.theme_pastel
  chart.labels = labels
  chart.title = metric
  chart.marker_font_size = 10
  
  processed_json.each_with_index do |json, i|
    chart.data names[i], json.values, COLOR[i]
  end

  chart.write "#{metric}.png"
end