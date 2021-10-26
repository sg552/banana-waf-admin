class CadexBase < ActiveRecord::Base
  self.abstract_class = true
  connects_to database: { writing: :cadex, reading: :cadex}
end
