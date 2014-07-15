require 'gruff'
require 'json'
require 'csv'

COLOR = ["#ff0000", "#00ff00", "#0000ff", "#ffff00", "#00ff", "#ff00ff"]
def process(chart, metric)
  d = {}
  chart.each do |k, v|
    d[k.to_i] = v[metric].to_f
  end
  return Hash[d.sort]
end

json_array = []
names = []
Dir["*.json"].each_with_index do |file, i|
  json_array[i] = JSON.parse(File.read(file))   
  names[i] = file.split(".").first
end


metrics = ["connection_rate_per_sec", "connection_time_avg", "total_test_duration", "reply_status_2xx", "reply_rate_avg", "reply_time_response"]


metrics.each do |metric|
  processed_json = []
  json_array.each_with_index do |array, i|
    processed_json[i] = process(array, metric)
  end
  
  labels = {}
  (0..1000).each do |i|    
    if (i % 100) == 0
      labels[i/10] = i.to_s
    end
  end

  chart = Gruff::Line.new(1024)

  chart.theme_pastel
  chart.labels = labels
  chart.title = metric
  chart.marker_font_size = 10
  chart.line_width = 1
  chart.hide_dots = true
  chart.marker_count = 10
  processed_json.each_with_index do |json, i|
    # write data to chart
    chart.data names[i], json.values, COLOR[i]
    # create CSV
    CSV.open("csv/#{metric}_#{names[i]}.csv", "w") do |csv|      
      json.sort.each do |a|
        csv << a
      end
    end

  end

  chart.write "images/#{metric}.png"
end