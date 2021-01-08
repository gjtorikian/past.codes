# frozen_string_literal: true

require 'graphql/client'
require 'graphql/client/http'

class GitHubClient
  include AuthHelper

  STARS_QUERY = <<~GRAPHQL
    query($username: String!, $hasPublicRepoScope: Boolean!, $after: String) {
      user(login: $username) {
        starredRepositories(after: $after, first: 100, ownedByViewer:false, orderBy: {field: STARRED_AT, direction: ASC}) {
          totalCount
          edges {
            starredAt
            node {
              nameWithOwner
              description
              primaryLanguage {
                name
              }
              ...PublicRepoPlatformInfo
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

    fragment PublicRepoPlatformInfo on Repository {
      fundingLinks {
        platform @include(if: $hasPublicRepoScope)
        url @include(if: $hasPublicRepoScope)
      }
    }
  GRAPHQL

  def initialize(encrypted_github_token)
    user_access_token = auth_decrypt(encrypted_github_token)
    @rest_client = Octokit::Client.new(access_token: user_access_token)
    @graphql_client = Graphlient::Client.new('https://api.github.com/graphql',
                                             http_options: {
                                               read_timeout: 20,
                                               write_timeout: 30
                                             },
                                             headers: { 'Authorization' => "bearer #{user_access_token}" })
  end

  def fetch_primary_email_and_scopes
    emails = @rest_client.emails.presence || []
    has_primary_email = emails.select { |e| e[:primary] }
    primary_email = (has_primary_email.presence || [{}]).first[:email] || ''
    response = @rest_client.last_response
    scopes = (response.headers['x-oauth-scopes'] || '').delete(' ').split(',')
    {
      primary_email: primary_email,
      scopes: scopes
    }
  end

  def fetch_stars(github_username, has_public_repo_scope: false)
    collect_starred_repos(STARS_QUERY, github_username, has_public_repo_scope, nil)
  end

  # Iterative recursion, collect results in all_starred_repos array.
  private def collect_starred_repos(query, github_username, has_public_repo_scope, end_cursor, all_starred_repos = [])
    result = @graphql_client.query(query, { username: github_username, hasPublicRepoScope: has_public_repo_scope, after: end_cursor })

    starred_repos = result.data.user.starred_repositories.edges.map do |edge|
      owner, name = edge.node.name_with_owner.split('/')
      description = edge.node.description&.strip
      primary_language = edge.node.primary_language
      funding_links = edge.node.funding_links
      {
        starred_at: edge.starred_at.to_datetime,
        repository: {
          name: name,
          owner: owner,
          description: description,
          primary_language: primary_language,
          funding_links: funding_links
        }
      }
    end

    all_starred_repos += starred_repos
    paging = result.data.user.starred_repositories.page_info
    if paging.has_next_page
      collect_starred_repos(query, github_username, has_public_repo_scope, paging.end_cursor, all_starred_repos)
    else
      all_starred_repos
    end
  end
end
