require "fileutils"

class Deployer

	include FileUtils
	
	def initialize
	
		@deploy_data = nil
		
	end
	
	def load_config(conf_file = "deploy")
	
		File.open(conf_file) do |f|
		
			@deploy_data = []
			
			first_section = true
			
			in_dir_section = false
			
			dir_files = nil
			
			src_dir = nil
			
			dst_dir = nil
			
			f.each_line do |l|
			
				if l =~ /\[(.*):(.*)\]/
				
					if !first_section
					
						@deploy_data << {
										 :src_dir=>src_dir,
									  	 :dst_dir=>dst_dir,
									  	 :files=>dir_files
									    }
					end
					
					src_dir = $1
					
					dst_dir = $2
					
					dir_files = []
					
					in_dir_section = true
					
					first_section = false
					
					next
					
				end
				
				if in_dir_section
				
					dir_files << l
					
				end
				
			end
			
			# last section in config file
			
			@deploy_data << {
							 :src_dir=>src_dir,
							 :dst_dir=>dst_dir,
							 :files=>dir_files
							 }
							
		end
		
	end
	
	def deploy
	
		@deploy_data.each do |dd|
		
			deployed_files = []
			
			dd[:files].each do |f_list|
			
				if f_list =~ /^@/
				
					Dir[f_list.chomp].each do |f|
					
						deployed_files << f
						
					end
					
				else
				
					deployed_files << f_list.chomp
					
				end
				
			end
			
			puts
			
			puts "\t[#{dd[:src_dir]}] => [#{dd[:dst_dir]}]"
			
			puts
			
			mkdir_p(dd[:dst_dir])
			
			deployed_files.each do |df|
			
				print "\t#{df} ... "
				
				begin
				
					cp(dd[:src_dir] + "/" + df, dd[:dst_dir]+ "/" +df, :preserve=>true)
					
					puts "OK"
					
				rescue
				
					puts "FAILED"
					
				end
				
			end
			
		end
		
	end
	
end

d = Deployer.new

d.load_config

d.deploy