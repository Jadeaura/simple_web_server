require 'socket'               # Get sockets from stdlib
require 'json'
require 'erb'

server = TCPServer.open(2000)  # Socket to listen on port 2000
loop {                         # Servers run forever
  client = server.accept       # Wait for a client to connect
  print "Client connected"
  request = ""
  content_length = 0
  length = 0
  while line = client.readline
    p line
    if line.match("Content-Length")
      content_length = line.scan(/\d+/)[0].to_i
    end
    if line.match(/^\r\n/)
      body = true
    end
    request << line

    if body
      length += line.chomp.length
    end
    if body == true && length >= content_length
      break
    end
  end

  headers,content = request.split("\r\n\r\n", 2)
  if content then content.chomp! end
  first_line, headers = headers.split("\r\n", 2)
  request_type,path,version = first_line.split

  response_head = ""
  response_body = ""

  case request_type
  when "GET"
    if File.exists?("#{path}")
      response_body = File.read(path)
      file_length = response_body.size
      status_code = "200 Ok"
    else
      response_body = "YOU FOUND....nothing."
      status_code = "404 File not found"
    end
    response_head = "#{version} #{status_code}\r\nDate: #{Time.now.ctime}\r\nContent-Length: #{file_length}\r\n\r\n"
  when "POST"
    if File.exists?("#{path}")
      params = JSON.parse(content)
      template = File.read(path)
      response_body = ERB.new(template).result(binding)
      file_length = response_body.size
      status_code = "200 Ok"
    else
      response_body = "YOU POSTED....nothing."
      status_code = "404 File not found"
    end
    response_head = "#{version} #{status_code}\r\nDate: #{Time.now.ctime}\r\nContent-Length: #{file_length}\r\n\r\n"
  else
    response_body = "Why would you do that?"
    status_code = "400 Bad request"
    response_head = "#{version} #{status_code}\r\nDate: #{Time.now.ctime}\r\nContent-Length: #{file_length}\r\n\r\n"
  end

  client.puts response_head + response_body
  client.puts "Closing the connection. Bye!"
  client.close                 # Disconnect from the client
}