require 'railsless-deploy'


# I got tired of uploading to /tmp then moving to the correct location, so these two convenience methods will save you a lot of time in the long run. 
# Helper method to upload to /tmp then use sudo to move to correct location.
def put_sudo(data, to)
  filename = File.basename(to)
  to_directory = File.dirname(to)
  put data, "/tmp/#{filename}"
  run "#{sudo} mv /tmp/#{filename} #{to_directory}"
end
 
# Helper method to create ERB template then upload using sudo privileges (modified from rbates)
def template_sudo(from, to)
  erb = File.read(File.expand_path("../templates/#{from}", __FILE__))
  put_sudo ERB.new(erb).result(binding), to
end

