require 'digest/sha1'
class User < ActiveRecord::Base
  attr_accessible :name, :mobile_number, :answer, :number1, :number2, :email

  validates :name,  :presence => true
  validates :email, :uniqueness => true, :presence => true, 
            :format => { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
            :on => :create }
  validates :mobile_number, :numericality => true

  validate :mobile_number_non_blank
  validate :mobile_number_invalid

#  validate :answer_non_blank
#  validate :answer_is_invalid
  
  # Generates a random string from a set of easily readable characters
  def self.generate_activation_code(size = 6)
    charset = %w{ 2 3 4 6 7 9 A C D E F G H J K M N P Q R T V W X Y Z}
    (0...size).map{ charset.to_a[rand(charset.size)] }.join
  end

  def generate_first_number(size = 1)
    charset = %w{ 1 2 3 4 6 7 9}
    (0...size).map{ charset.to_a[rand(charset.size)] }.join
  end

  def generate_second_number(size = 1)
    charset = %w{ 1 2 3 4 6 7 9}
    (0...size).map{ charset.to_a[rand(charset.size)] }.join
  end

  def self.authenticate(random_pass, mobile_number)
    user = self.find_by_random_pass_and_is_active_and_registered(random_pass, true, true)
      if user
        expected_mobile_number = encrypted_mobile_number(mobile_number, user.salt)
      if user.phone_number != expected_mobile_number
        user = nil
      end
      end
      user
  end

  def self.renew_access_token(email, mobile)
    user = self.find_by_email(email)
    unless user.nil?
      if user
        expected_mobile_number = encrypted_mobile_number(mobile, user.salt)
      if user.phone_number != expected_mobile_number
        user = nil
      end
      end
      user
    end
  end

  def self.authenticate_manager(random_pass, mobile_number)
    user = self.find_by_random_pass_and_is_active_and_manager(random_pass, true, true)
      if user
        expected_mobile_number = encrypted_mobile_number(mobile_number, user.salt)
      if user.phone_number != expected_mobile_number
        user = nil
      end
      end
      user
  end

  def self.activate_user_account(user_code)
    user = self.find_by_phone_number(user_code)
    user.update_attribute(:is_active, true)
    user.update_attribute(:registered, true)
  end

  def solution(n1,n2)
    result = n1 + n2
    result
  end

  def mobile_number
    @mobile_number
  end

  def answer
    @answer
  end

  def answer=(ans)
    @answer = ans
    return if ans.blank?
  end

  def number2
    @number2
  end

  def number2=(n2)
    @answer = n2
    return if n2.blank?
  end

  def number1
    @number1
  end

  def number1=(n1)
    @answer = n1
    return if n1.blank?
  end

  def mobile_number=(mob)
    @mobile_number = mob
    return if mob.blank?
    create_new_salt
    self.phone_number = User.encrypted_mobile_number(self.mobile_number, self.salt)
  end


  private
  
  def mobile_number_non_blank
    errors.add(:mobile_number, "missing") if phone_number.blank?
  end

  def mobile_number_invalid
    errors.add(:mobile_number, "is invalid") if mobile_number.first(3) != "077" || mobile_number.length != 10
  end

   def answer_non_blank
    errors.add(:answer, "missing") if answer.blank?
  end

  def self.encrypted_mobile_number(mobile_number, salt)
    string_to_hash = mobile_number + "wibble" + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end
  
  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end

#  def answer_is_invalid
#    result = number1.to_i + number2.to_i
#    errors.add(:answer, " provided is invalid") if answer.blank? || answer != result.to_i
#  end

end