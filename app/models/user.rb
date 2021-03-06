class User < ActiveRecord::Base
  attr_accessible :user_positions_attributes, :alumni, :birthday, :role, :class_name, :first_name, :last_name, :password_digest, :pledge_name, :phone, :password, :password_confirmation

  has_secure_password
  validates_presence_of :password, :password_confirmation, :on => :create
	validates_format_of :phone, :with => /^\(?\d{3}\)?[-. ]?\d{3}[-. ]?\d{4}$/, :message => "should be 10 digits (area code needed) and delimited with dashes only", :allow_blank => true
  
  before_save :reformat_phone

  has_many :transactions, :dependent => :destroy
  has_many :event_attendances, :dependent => :destroy
	has_many :events, :through => :event_attendances, :dependent => :destroy
  has_many :user_positions, :dependent => :destroy
  has_many :positions, :through => :user_positions, :dependent => :destroy
  has_many :semesters, :through => :user_positions, :dependent => :destroy

  accepts_nested_attributes_for :user_positions, :reject_if => lambda {|up| up[:position_id].blank?} , :allow_destroy => true


	scope :alphabetical, order('last_name, first_name')
  scope :student, where('alumni = ?', false)

  CLASS_LIST = ['Alpha', 'Beta', 'Gamma', 'Delta', 'Eta', 'Zeta', 'Theta', 'Iota', 'Lambda', 'Mu', 'Nu', 'Xi', 'Omicron', 'Pi', 'Rho', 'Sigma', 'Tau', 'Upsilon', 'Phi']
  ROLE_LIST = ['admin', 'user']

  def proper_name
  	"#{self.first_name} #{self.last_name}"
  end

  def present?(event)
    EventAttendance.for_event(event.id).each do |ea|
      if ea.user_id == self.id
        return ea.present
      end
    end
    return true
  end

  def late?(event)
    EventAttendance.for_event(event.id).each do |ea|
      if ea.user_id == self.id
        return ea.late
      end
    end
    return false
  end

  def self.find_by_full_name(full_name)
    User.all.each do |user|
      if user.proper_name == full_name
        return user
      end
    end
  end

  def take_attendance
  	attendance = EventAttendance.for_user(self.id)
  	present = Array.new
  	late = Array.new
  	absent = Array.new
  	attendance.each do |e|
  		if e.present
  			present << e
  		else
  			absent << e
  		end
  		if e.late
  			late << e
  		end
  	end
		ea = Array.new
		ea << present << late << absent
		ea  
  end

  private
  def reformat_phone
    phone = self.phone.to_s  # change to string in case input as all numbers 
    phone.gsub!(/[^0-9]/,"") # strip all non-digits
    self.phone = phone       # reset self.phone to new string
  end
end
