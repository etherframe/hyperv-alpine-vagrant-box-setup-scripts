require "digest/md5"

Vagrant.configure("2") do |config|
	config.vm.box = "etherframe/alpine64-test"
	config.ssh.shell = "ash"
	config.vm.provider "hyperv"

	smb_username = Digest::MD5.hexdigest(__FILE__).slice(0, 20)
	smb_password = "vagrant"

	config.vm.synced_folder ".", "/vagrant", create: true, smb_username: smb_username, smb_password: smb_password

	# Configure "before up" trigger that adds SMB user.

	config.trigger.before :up do |trigger|
		trigger.info = "Add SMB user!"
		trigger.run = {inline: "net user #{smb_username} #{smb_password} /add"}
	end

	# Configure third "after destroy" trigger that deletes SMB user.

	config.trigger.after :destroy do |trigger|
		trigger.info = "Delete SMB user!"
		trigger.on_error = :continue
		trigger.run = {inline: "net user #{smb_username} /delete"}
	end
end
