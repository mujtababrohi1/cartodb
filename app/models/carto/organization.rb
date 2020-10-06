require 'active_record'
require_relative '../../helpers/data_services_metrics_helper'
require_dependency 'carto/helpers/auth_token_generator'
require_dependency 'carto/carto_json_serializer'
require_dependency 'carto/helpers/organization_commons'

module Carto
  class Organization < ActiveRecord::Base

    include DataServicesMetricsHelper
    include AuthTokenGenerator
    include Carto::OrganizationSoftLimits
    include Carto::OrganizationCommons

    belongs_to :owner, class_name: Carto::User, inverse_of: :owned_organization

    has_many :users, -> { order(:username) }, inverse_of: :organization
    has_many :groups, -> { order(:display_name) }, inverse_of: :organization
    has_many :assets, class_name: Carto::Asset, dependent: :destroy, inverse_of: :organization
    has_many :notifications, -> { order('created_at DESC') }, dependent: :destroy
    has_many :connector_configurations, inverse_of: :organization, dependent: :destroy
    has_many :oauth_app_organizations, inverse_of: :oauth_app, dependent: :destroy

    validates :auth_saml_configuration, carto_json_symbolizer: true

    serialize :auth_saml_configuration, CartoJsonSymbolizerSerializer

    before_validation :ensure_auth_saml_configuration

    before_destroy :destroy_groups_with_extension

    def self.find_by_database_name(database_name)
      Carto::Organization.
        joins('INNER JOIN users ON organizations.owner_id = users.id').
        where('users.database_name = ?', database_name).first
    end

    ##
    # SLOW! Checks redis data (geocoding and isolines) for every user in every organization
    # delta: get organizations who are also this percentage below their limit.
    #        example: 0.20 will get all organizations at 80% of their map view limit
    #
    def self.overquota(delta = 0)
      Carto::Organization.find_each.select do |o|
        begin
          limit = o.geocoding_quota.to_i - (o.geocoding_quota.to_i * delta)
          over_geocodings = o.get_geocoding_calls > limit
          limit = o.here_isolines_quota.to_i - (o.here_isolines_quota.to_i * delta)
          over_here_isolines = o.get_here_isolines_calls > limit
          limit = o.obs_snapshot_quota.to_i - (o.obs_snapshot_quota.to_i * delta)
          over_obs_snapshot = o.get_obs_snapshot_calls > limit
          limit = o.obs_general_quota.to_i - (o.obs_general_quota.to_i * delta)
          over_obs_general = o.get_obs_general_calls > limit
          limit = o.twitter_datasource_quota.to_i - (o.twitter_datasource_quota.to_i * delta)
          over_twitter_imports = o.twitter_imports_count > limit
          limit = o.mapzen_routing_quota.to_i - (o.mapzen_routing_quota.to_i * delta)
          over_mapzen_routing = o.get_mapzen_routing_calls > limit
          over_geocodings || over_twitter_imports || over_here_isolines || over_obs_snapshot || over_obs_general || over_mapzen_routing
        rescue Carto::Organization::OrganizationWithoutOwner => error
          log_warning(message: 'Skipping inconsistent organization', organization: o, exception: error)
          false
        end
      end
    end

    delegate :destroy_cascade, to: :sequel_organization
    def sequel_organization
      ::Organization[id]
    end

    def default_password_expiration_in_d
      Cartodb.get_config(:passwords, 'expiration_in_d')
    end

    def valid_builder_seats?(users = [])
      remaining_seats(excluded_users: users).positive?
    end

    def remaining_seats(excluded_users: [])
      seats - assigned_seats(excluded_users: excluded_users)
    end

    def assigned_seats(excluded_users: [])
      builder_users.count { |u| !excluded_users.map(&:id).include?(u.id) }
    end

    def valid_disk_quota?(quota = default_quota_in_bytes)
      unassigned_quota >= quota
    end

    # Make code more uniform with user.database_schema
    def database_schema
      name
    end

    ####

    def quota_dates(options)
      date_to = (options[:to] ? options[:to].to_date : Date.today)
      date_from = (options[:from] ? options[:from].to_date : last_billing_cycle)
      return date_from, date_to
    end

    def last_billing_cycle
      owner ? owner.last_billing_cycle : Date.today
    end

    def get_geocoding_calls(options = {})
      require_organization_owner_presence!
      date_from, date_to = quota_dates(options)
      get_organization_geocoding_data(self, date_from, date_to)
    end

    def get_here_isolines_calls(options = {})
      require_organization_owner_presence!
      date_from, date_to = quota_dates(options)
      get_organization_here_isolines_data(self, date_from, date_to)
    end

    def get_mapzen_routing_calls(options = {})
      require_organization_owner_presence!
      date_from, date_to = quota_dates(options)
      get_organization_mapzen_routing_data(self, date_from, date_to)
    end

    def get_obs_snapshot_calls(options = {})
      require_organization_owner_presence!
      date_from, date_to = quota_dates(options)
      get_organization_obs_snapshot_data(self, date_from, date_to)
    end

    def get_obs_general_calls(options = {})
      require_organization_owner_presence!
      date_from, date_to = quota_dates(options)
      get_organization_obs_general_data(self, date_from, date_to)
    end

    def twitter_imports_count(options = {})
      require_organization_owner_presence!
      date_to = (options[:to] ? options[:to].to_date : Date.today)
      date_from = (options[:from] ? options[:from].to_date : owner.last_billing_cycle)
      Carto::SearchTweet.twitter_imports_count(users.joins(:search_tweets), date_from, date_to)
    end
    alias get_twitter_imports_count twitter_imports_count

    def owner?(user)
      owner_id == user.id
    end

    def remaining_geocoding_quota(options = {})
      remaining = geocoding_quota.to_i - get_geocoding_calls(options)
      (remaining > 0 ? remaining : 0)
    end

    def remaining_here_isolines_quota(options = {})
      remaining = here_isolines_quota.to_i - get_here_isolines_calls(options)
      (remaining > 0 ? remaining : 0)
    end

    def remaining_mapzen_routing_quota(options = {})
      remaining = mapzen_routing_quota.to_i - get_mapzen_routing_calls(options)
      (remaining > 0 ? remaining : 0)
    end

    def remaining_obs_snapshot_quota(options = {})
      remaining = obs_snapshot_quota.to_i - get_obs_snapshot_calls(options)
      (remaining > 0 ? remaining : 0)
    end

    def remaining_obs_general_quota(options = {})
      remaining = obs_general_quota.to_i - get_obs_general_calls(options)
      (remaining > 0 ? remaining : 0)
    end

    def to_poro
      {
        created_at:       created_at,
        description:      description,
        discus_shortname: discus_shortname,
        display_name:     display_name,
        id:               id,
        name:             name,
        owner: {
          id:         owner ? owner.id : nil,
          username:   owner ? owner.username : nil,
          avatar_url: owner ? owner.avatar_url : nil,
          email:      owner ? owner.email : nil,
          groups:     owner && owner.groups ? owner.groups.map { |g| Carto::Api::GroupPresenter.new(g).to_poro } : []
        },
        admins:                    users.select(&:org_admin).map { |u| { id: u.id } },
        quota_in_bytes:            quota_in_bytes,
        unassigned_quota:          unassigned_quota,
        geocoding_quota:           geocoding_quota,
        map_view_quota:            map_view_quota,
        twitter_datasource_quota:  twitter_datasource_quota,
        map_view_block_price:      map_view_block_price,
        geocoding_block_price:     geocoding_block_price,
        here_isolines_quota:       here_isolines_quota,
        here_isolines_block_price: here_isolines_block_price,
        obs_snapshot_quota:        obs_snapshot_quota,
        obs_snapshot_block_price:  obs_snapshot_block_price,
        obs_general_quota:         obs_general_quota,
        obs_general_block_price:   obs_general_block_price,
        geocoder_provider:         geocoder_provider,
        isolines_provider:         isolines_provider,
        routing_provider:          routing_provider,
        mapzen_routing_quota:       mapzen_routing_quota,
        mapzen_routing_block_price: mapzen_routing_block_price,
        seats:                     seats,
        twitter_username:          twitter_username,
        location:                  twitter_username,
        updated_at:                updated_at,
        website:                   website,
        admin_email:               admin_email,
        avatar_url:                avatar_url,
        user_count:                users.count,
        password_expiration_in_d:  password_expiration_in_d
      }
    end

    def tags(type, exclude_shared=true)
      users.map { |u| u.tags(exclude_shared, type) }.flatten
    end

    def public_vis_by_type(type, page_num, items_per_page, tags, order = 'updated_at', version = nil)
      CartoDB::Visualization::Collection.new.fetch(
          user_id:  self.users.map(&:id),
          type:     type,
          privacy:  CartoDB::Visualization::Member::PRIVACY_PUBLIC,
          page:     page_num,
          per_page: items_per_page,
          tags:     tags,
          order:    order,
          o:        { updated_at: :desc },
          version:  version
      )
    end

    def signup_page_enabled
      whitelisted_email_domains.present? && auth_enabled?
    end

    def auth_enabled?
      auth_username_password_enabled || auth_google_enabled || auth_github_enabled || auth_saml_enabled?
    end

    def total_seats
      seats + viewer_seats
    end

    def remaining_viewer_seats(excluded_users: [])
      viewer_seats - assigned_viewer_seats(excluded_users: excluded_users)
    end

    def assigned_viewer_seats(excluded_users: [])
      viewer_users.count { |u| !excluded_users.map(&:id).include?(u.id) }
    end

    def notify_if_disk_quota_limit_reached
      ::Resque.enqueue(::Resque::OrganizationJobs::Mail::DiskQuotaLimitReached, id) if disk_quota_limit_reached?
    end

    def notify_if_seat_limit_reached
      ::Resque.enqueue(::Resque::OrganizationJobs::Mail::SeatLimitReached, id) if seat_limit_reached?
    end

    def database_name
      owner&.database_name
    end

    def revoke_cdb_conf_access
      users.map { |user| user.db_service.revoke_cdb_conf_access }
    end

    def create_group(display_name)
      Carto::Group.create_group_with_extension(self, display_name)
    end

    def name_to_display
      display_name || name
    end

    def max_import_file_size
      owner ? owner.max_import_file_size : ::User::DEFAULT_MAX_IMPORT_FILE_SIZE
    end

    def max_import_table_row_count
      owner ? owner.max_import_table_row_count : ::User::DEFAULT_MAX_IMPORT_TABLE_ROW_COUNT
    end

    def max_concurrent_import_count
      owner ? owner.max_concurrent_import_count : ::User::DEFAULT_MAX_CONCURRENT_IMPORT_COUNT
    end

    def max_layers
      owner ? owner.max_layers : ::User::DEFAULT_MAX_LAYERS
    end

    def assigned_quota
      users.sum(:quota_in_bytes).to_i
    end

    def unassigned_quota
      quota_in_bytes - assigned_quota
    end

    def require_organization_owner_presence!
      if owner.nil?
        raise Carto::Organization::OrganizationWithoutOwner.new(self)
      end
    end

    def auth_saml_enabled?
      auth_saml_configuration.present?
    end

    def builder_users
      users.reject(&:viewer)
    end

    def viewer_users
      users.select(&:viewer)
    end

    def admin?(user)
      user.belongs_to_organization?(self) && user.organization_admin?
    end

    def non_owner_users
      owner ? users.where.not(id: owner.id) : users
    end

    def inheritable_feature_flags
      inherit_owner_ffs ? owner.self_feature_flags : Carto::FeatureFlag.none
    end

    def dbdirect_effective_ips
      owner.dbdirect_effective_ips
    end

    def dbdirect_effective_ips=(ips)
      owner.dbdirect_effective_ips = ips
    end

    def remaining_twitter_quota
      remaining = twitter_datasource_quota - twitter_imports_count
      (remaining > 0 ? remaining : 0)
    end

    def get_api_calls(options = {})
      users.map { |u| u.get_api_calls(options).sum }.sum
    end

    def require_organization_owner_presence!
      raise Carto::Organization::OrganizationWithoutOwner.new(self) unless owner
    end

    ## TODO: make private once model is fully migrated

    def destroy_non_owner_users
      non_owner_users.each do |user|
        user.ensure_nonviewer
        user.shared_entities.map(&:entity).uniq.each(&:delete)
        user.sequel_user.destroy_cascade
      end
    end

    def destroy_assets
      assets.map { |asset| Carto::Asset.find(asset.id) }.map(&:destroy).all?
    end

    def destroy_groups
      return unless groups

      groups.map { |g| Carto::Group.find(g.id).destroy_group_with_extension }

      reload
    end

    # Returns true if disk quota won't allow new signups with existing defaults
    def disk_quota_limit_reached?
      unassigned_quota < default_quota_in_bytes
    end

    # Returns true if seat limit will be reached with new user
    def seat_limit_reached?
      (remaining_seats - 1) < 1
    end

    def public_vis_count_by_type(type)
      CartoDB::Visualization::Collection.new.fetch(
        user_id: users.map(&:id),
        type: type,
        privacy: CartoDB::Visualization::Member::PRIVACY_PUBLIC,
        per_page: CartoDB::Visualization::Collection::ALL_RECORDS
      ).count
    end

    def name_exists_in_users?
      !::User.where(username: name).first.nil?
    end

    private

    def ensure_auth_saml_configuration
      self.auth_saml_configuration ||= {}
    end

    def destroy_groups_with_extension
      return unless groups

      groups.each(&:destroy_group_with_extension)

      reload
    end

  end
end
