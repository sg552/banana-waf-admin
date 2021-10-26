Manager.delete_all
Manager.create! email: 'ww@ww.com', password: '123456', role_id: 1
SystemVariable.delete_all
SystemVariable.create! name: 'max_failed_manager_login_attemps', value: 5, comment: '管理员最大的错误登录次数'
