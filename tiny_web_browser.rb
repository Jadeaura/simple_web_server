require 'socket'
require 'json'

host = 'localhost'
port = 2000
path = "index.html"

print "Post or get?\nAnswer: "
while input = gets.chomp.downcase
  case input
  when "post"
    print "Name: "
    name = gets.chomp
    print "Email: "
    email = gets.chomp
    form = {:viking => {:name=>name, :email=>email}}.to_json
    request = "POST thanks.html HTTP/1.0\r\nContent-Length: #{form.size}\r\n\r\n#{form}\r\n"
    break
  when "get"
    request = "GET #{path} HTTP/1.0\r\n\r\n"
    break
  else
    puts "Try again"
  end
end

socket = TCPSocket.open(host,port)
socket.print(request)
response = socket.read

headers,body = response.split("\r\n\r\n", 2)
puts headers + "\n"
print body