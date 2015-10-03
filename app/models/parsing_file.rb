class ParsingFile < ActiveRecord::Base
  has_attached_file :file
  validates_attachment :file, 
    content_type: 'text/csv',
    path: ":rails_root/parsing/:id/:filename"

  enum state: [:waiting_for_parsing, :parsing, :parsed, :error]
end
