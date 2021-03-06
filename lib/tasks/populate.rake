namespace :db do

  desc "Erase and fill database"
  # creating a rake task within db namespace called 'populate'
  # executing 'rake db:populate' will cause this script to run
  task :populate => :environment do
    # Need two gems to make this work: faker & populator
    # Docs at: http://populator.rubyforge.org/
    require 'populator'
    require 'spreadsheet'
    
    # Step 0: clear any old data in the db
    [User, Event, EventAttendance].each(&:delete_all)
    
    book = Spreadsheet.open 'lib/assets/brothers.xls'

    # Seed database with brother information
    brothers = book.worksheet 'Brothers'

    brothers.each do |row|
      if !row[0].blank?
        user = User.new
        if row[0].split(' ').size > 2
          name = row[0].split(' ')
          user.first_name = "#{name[0]} #{name[1]}"
          user.last_name = name[2]
        else
          user.first_name, user.last_name = row[0].split(' ')
        end
        user.pledge_name = row[1]
        user.phone = row[2]
        user.class_name = row[3].capitalize
        if (!row[4].nil?)
          user.birthday = row[4]
        end
        user.password = "1234"
        user.password_confirmation = "1234"
        user.role = row[5]
        user.alumni = row[6]
        user.save!
        p "saved #{user.proper_name}"
      end
    end
   
  end
end      
