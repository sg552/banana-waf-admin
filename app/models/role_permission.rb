class RolePermission < ApplicationRecord

	has_many :children, class_name: 'RolePermission', foreign_key: 'parent_id'

	scope :parent_permission, -> { where("comment is not null and parent_id is null") }

	IGNORE_ENTRIES = [".", "..", ".svn", "application_controller.rb", "concerns"]
	def self.scan_controllers
		@controller_name_ids = []
		@action_name_id = []
		# 指定要忽略的文件（夹）
		Dir.entries("#{RAILS_ROOT}/app/controllers").each do |entry|
			next if IGNORE_ENTRIES.include?(entry)
				# 判断是否是文件夹
				if !entry.include?('controller.rb')
					self.get_controller(entry)
				else
					self.scan_action(entry)
				end
		end
		RolePermission.delete_controller_and_action
		RolePermission.scan_dabase
	end

	# 二级文件夹处理
	def self.get_controller(dictry)
		Dir.entries("#{RAILS_ROOT}/app/controllers/#{dictry}").each do |entry|
			next if IGNORE_ENTRIES.include?(entry)
			self.scan_action("#{dictry}/#{entry}")
		end
	end

	# 读取控制器内的内容，然后找出action
	def self.scan_action(file)
		File.open("#{RAILS_ROOT}/app/controllers/#{file}") do |f|
			while f.gets
				if $_.include?("class") && $_.include?("<") and f.lineno < 10
					controller_name =  file[/(.*)_controller.rb/, 1]
					controller_name = controller_name[/\/(.*)/, 1] if controller_name.include?("\/")
					if $_[/#\s*(.*)/, 1]
						role_permission = RolePermission.find_by_name(controller_name)
						if role_permission
							role_permission.update(comment: $_[/#\s*(.*)/, 1])
						else
							role_permission = RolePermission.create(:name => controller_name, comment: $_[/#\s*(.*)/, 1])
						end
					else
						# 删除的controller（去掉了后面的注释的）
						controller_name = RolePermission.find_by_name(controller_name)
						if controller_name
							@controller_name_ids << controller_name.id
							self.get_action($_, controller_name)
						end
					end
				end
				self.get_action($_, role_permission) if role_permission
			end
		end
	end

	def self.get_action(action, role_permission)
		# 如果某行不含括号并且以一或多个空格、tab符开始后面是def再后面是空格的开始
		name = action[/\s+def ([_a-z0-9]+)/, 1]
		history_role_permission = RolePermission.where(parent_id: role_permission.id, :name => name)
		if !action.include?("(") && action =~ /\s+def / && action[/#\s*(.*)/, 1]
			if history_role_permission.empty?
				# 创建新纪录
				RolePermission.create(parent_id: role_permission.id, name: name, comment: action[/#\s*(.*)/, 1])
			else
				# 更新已有数据的注释
				history_role_permission.first.update(comment: action[/#\s*(.*)/, 1])
			end
		elsif !history_role_permission.empty? &&  action[/#\s*(.*)/, 1].nil?
			# 删除的action（去掉了后面的注释的）
			@action_name_id << history_role_permission.first.id
		end
	end

	def self.scan_dabase
		RolePermission.where(parent_id: nil).each do |parent|
			if parent.children.empty?
				parent.delete
			end
		end
	end

	# 删除某个方法
	def self.delete_controller_and_action
		# 删除权限表中的对应id数据
		RolePermission.where("id in (?) or parent_id in (?)", @controller_name_ids + @action_name_id, @controller_name_ids).delete_all
		# 删除roles表中对应的权限
		Role.update_role_permission_ids(@controller_name_ids, @action_name_id)
	end
end
