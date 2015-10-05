class Download < ActiveRecord::Base
  enum state: [:waiting_for_preparing, :preparing_file, :ready_for_download, :error]
end
