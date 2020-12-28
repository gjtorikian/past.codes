# frozen_string_literal: true

require 'graphql/client'
require 'graphql/client/http'

module ClientHelper
  STARS_QUERY = <<~GRAPHQL
    query($username: String!, $after: String) {
      user(login: $username) {
        starredRepositories(ownedByViewer:false, first: 100, after: $after, orderBy: {field: STARRED_AT, direction: ASC}) {
          edges {
            starredAt
            node {
              nameWithOwner
            }
          }
          pageInfo {
            startCursor
            hasNextPage
            endCursor
          }
        }
      }
    }
  GRAPHQL

  CLIENT = Graphlient::Client.new('https://api.github.com/graphql',
                                  http_options: {
                                    read_timeout: 20,
                                    write_timeout: 30
                                  })

  def fetch_stars(current_user)
    user_access_token = auth_decrypt(current_user.encrypted_gh_token)

    CLIENT.options[:headers] = { 'Authorization' => "bearer #{user_access_token}" }

    collect_starred_repos(CLIENT, STARS_QUERY, current_user.username, nil)
  end
  module_function :fetch_stars

  # Iterative recursion, collect results in all_starred_repos array.
  private def collect_starred_repos(client, query, username, end_cursor, all_starred_repos = [])
    result = client.query(query, { username: username, after: end_cursor })
    starred_repos = result.data.user.starred_repositories.edges.map { |e| "#{e.starred_at}: #{e.node.name_with_owner}" }
    all_starred_repos += starred_repos
    paging = result.data.user.starred_repositories.page_info
    if paging.has_next_page
      collect_starred_repos(client, query, username, paging.end_cursor, all_starred_repos)
    else
      all_starred_repos
    end
  end
  module_function :collect_starred_repos

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
