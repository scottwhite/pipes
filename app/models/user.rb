require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  # include Authentication::ByPassword
  # include Authentication::ByCookieToken
  # include Authorization::AasmRoles

  has_many :did_request_holders
  has_many :orders, dependent: :destroy
  has_many :phones, class_name: 'UserPhone', dependent: :destroy
  has_many :dids_user_phones, through: :phones
  has_many :active_dids, class_name: 'Did', finder_sql: %q{select dids.* from dids 
                                        inner join dids_user_phones dup on dup.did_id = dids.id
                                        inner join user_phones up on up.user_id = #{id}
                                        and up.id = dup.user_phone_id
                                        and dids.usage_state = #{Did::ACTIVE}}
  has_many :currently_using_dids, class_name: 'Did', finder_sql: %q{select dids.* from dids 
                                        inner join dids_user_phones dup on dup.did_id = dids.id
                                        inner join user_phones up on up.user_id = #{id}
                                        and up.id = dup.user_phone_id
                                        and dids.usage_state = #{Did::IN_USE}}
                                        
  has_many :current_dids, class_name: 'Did', finder_sql:  %q{select dids.* from dids 
                                                              inner join dids_user_phones dup on dup.did_id = dids.id
                                                              inner join user_phones up 
                                                              on up.user_id = #{id}
                                                              and up.id = dup.user_phone_id
                                                              and dup.expiration_date > now()}
  
  has_many :orders

  # validates_presence_of     :login
  # validates_length_of       :login,    :within => 3..40
  # validates_uniqueness_of   :login
  # validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  # validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  # validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message

  

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation, :receive_notifications



  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(email, phone)
    return nil if email.blank? || phone.blank?
    self.from_email_and_phone_number(email, phone)
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end
  
  def generate_token
    make_activation_code
  end
  
  def self.from_email_and_phone_number(email, number)
    self.find(:first, :joins=>[:phones], conditions: ["users.email = ? and user_phones.number = ?", email, UserPhone.convert_number(number)])
  end
  
  protected
    
  def make_activation_code
      self.deleted_at = nil
      self.activation_code = self.class.make_token
  end
  

end
