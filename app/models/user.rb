require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authorization::AasmRoles

  has_many :did_request_holders
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

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message

  

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation



  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_in_state :first, :active, :conditions => {:login => login.downcase} # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  def request_number(options={})
    phone = UserPhone.convert_number(options[:number])
    up = UserPhone.find_or_create_by_user_id_and_number(self.id, phone)
    up.order_and_assign(options)
  end

  protected
    
  def make_activation_code
      self.deleted_at = nil
      self.activation_code = self.class.make_token
  end
  

end
