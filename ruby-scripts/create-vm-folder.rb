require 'fileutils'

VM_STAT = [
    "dns-vm", "ansible-vm", "gitlab-vm", "nfs-vm", "node-1", "node-2", "kube", "test-node-1", "test-node-2" 
]

# Check and create folders 
main_folder = 'C:\Users\henze\Learning\VM\\'
puts "main_folder: " + main_folder 

VM_STAT.each do |vm_folder|
    full_path = main_folder + vm_folder + '\\'
    puts full_path
    unless File.directory?(full_path)
           FileUtils.mkdir_p(full_path)
           puts "folder created dest: " + full_path
    end 
    
    # delete directories
    #FileUtils.rm_r(full_path)

end