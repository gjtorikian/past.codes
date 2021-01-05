# frozen_string_literal: true

require 'graphql/client'
require 'graphql/client/http'

module AuthHelper
  def auth_encrypt(text)
    len   = ActiveSupport::MessageEncryptor.key_len
    salt  = SecureRandom.hex(len)
    key   = ActiveSupport::KeyGenerator.new(CRYPT_KEEPER).generate_key(salt, len)
    crypt = ActiveSupport::MessageEncryptor.new key
    encrypted_data = crypt.encrypt_and_sign text
    "#{salt}$$#{encrypted_data}"
  end

  def auth_decrypt(text)
    salt, data = text.split('$$')
    len = ActiveSupport::MessageEncryptor.key_len
    key = ActiveSupport::KeyGenerator.new(CRYPT_KEEPER).generate_key(salt, len)
    crypt = ActiveSupport::MessageEncryptor.new key
    crypt.decrypt_and_verify(data)
  end
end
