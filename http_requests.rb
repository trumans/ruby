require "net/http"
require "net/https"

# from http://www.rubyinside.com/nethttp-cheat-sheet-2940.html
puts "request to Goggle..."
g_uri = URI.parse("http://www.google.com/")
g_http = Net::HTTP.new(g_uri.host, g_uri.port)

g_request = Net::HTTP::Get.new(g_uri.request_uri)
g_response = g_http.request(g_request)
puts "code #{g_response.code}"
puts "body #{g_response.body}"
puts "=========="

# from http://danknox.github.io/2013/01/27/using-rubys-native-nethttp-library/
puts "request to wikipedia/buster..."
k_uri = URI.parse("https://en.wikipedia.org")
k_http = Net::HTTP.new(k_uri.host, k_uri.port)
k_http.use_ssl = true

k_request = Net::HTTP::Get.new("/wiki/Buster_Keaton")
k_response = k_http.request(k_request)
#k_response.instance_variables.each do |var|
#  puts "#{var}: #{k_response.instance_variable_get(var).inspect}"
#end
puts "code #{k_response.code}"
puts "body #{k_response.body[0..1000]}[truncated]"
