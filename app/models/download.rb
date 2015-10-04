class Download < ActiveRecord::Base
  enum state: [:waiting_for_preparing, :preparing_file, :ready_to_download, :error]
end
