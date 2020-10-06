require_relative '../controllers/carto/api/group_presenter'
require_relative '../helpers/data_services_metrics_helper'
require_relative './permission'
require_dependency 'carto/helpers/auth_token_generator'
require_dependency 'carto/helpers/organization_commons'

class Organization < Sequel::Model

  include CartodbCentralSynchronizable
  include DataServicesMetricsHelper
  include Carto::AuthTokenGenerator
  include Carto::OrganizationSoftLimits
  include Carto::OrganizationCommons

  Organization.raise_on_save_failure = true
  self.strict_param_setting = false

  one_to_many :users
  one_to_many :groups
  one_to_many :assets
  many_to_one :owner, class_name: '::User', key: 'owner_id'

  plugin :serialization, :json, :auth_saml_configuration

  plugin :validation_helpers

  DEFAULT_GEOCODING_QUOTA = 0
  DEFAULT_HERE_ISOLINES_QUOTA = 0
  DEFAULT_OBS_SNAPSHOT_QUOTA = 0
  DEFAULT_OBS_GENERAL_QUOTA = 0
  DEFAULT_MAPZEN_ROUTING_QUOTA = nil

  delegate(
    :default_password_expiration_in_d,
    :get_api_calls,
    :valid_builder_seats?,
    :remaining_seats,
    :assigned_seats,
    :builder_users,
    :valid_disk_quota?,
    :unassigned_quota,
    :assigned_quota,
    :database_schema,
    :last_billing_cycle,
    :get_geocoding_calls,
    :get_here_isolines_calls,
    :get_mapzen_routing_calls,
    :get_obs_snapshot_calls,
    :get_obs_general_calls,
    :twitter_imports_count,
    :non_owner_users,
    :remaining_geocoding_quota,
    :remaining_here_isolines_quota,
    :remaining_obs_snapshot_quota,
    :remaining_obs_general_quota,
    :remaining_mapzen_routing_quota,
    :to_poro,
    :tags,
    :public_vis_by_type,
    :signup_page_enabled,
    :auth_enabled?,
    :total_seats,
    :remaining_viewer_seats,
    :assigned_viewer_seats,
    :viewer_users,
    :admin?,
    :notify_if_disk_quota_limit_reached,
    :notify_if_seat_limit_reached,
    :database_name,
    :revoke_cdb_conf_access,
    :name_to_display,
    :max_import_file_size,
    :max_import_table_row_count,
    :max_concurrent_import_count,
    :max_layers,
    :auth_saml_enabled?,
    :inheritable_feature_flags,
    :get_twitter_imports_count,
    to: :carto_organization
  )

  def carto_organization
    if persisted?
      Carto::Organization.find_by(id: id)
    else
      Carto::Organization.new(attributes)
    end
  end

  def validate
    super
    validates_presence [:name, :quota_in_bytes, :seats]
    validates_unique   :name
    validates_format   (/\A[a-z0-9\-]+\z/), :name, message: 'must only contain lowercase letters, numbers & hyphens'
    validates_integer  :default_quota_in_bytes, :allow_nil => true
    validates_integer :geocoding_quota, allow_nil: false, message: 'geocoding_quota cannot be nil'
    validates_integer :here_isolines_quota, allow_nil: false, message: 'here_isolines_quota cannot be nil'
    validates_integer :obs_snapshot_quota, allow_nil: false, message: 'obs_snapshot_quota cannot be nil'
    validates_integer :obs_general_quota, allow_nil: false, message: 'obs_general_quota cannot be nil'
    validate_password_expiration_in_d

    if default_quota_in_bytes
      errors.add(:default_quota_in_bytes, 'Default quota must be positive') if default_quota_in_bytes <= 0
    end
    errors.add(:name, 'cannot exist as user') if name_exists_in_users?
    if whitelisted_email_domains.present? && !auth_enabled?
      errors.add(:whitelisted_email_domains, 'enable at least one auth. system or clear whitelisted email domains')
    end

    errors.add(:seats, 'cannot be less than the number of builders') if seats && remaining_seats < 0
    errors.add(:viewer_seats, 'cannot be less than the number of viewers') if viewer_seats && remaining_viewer_seats < 0
  end

  def validate_password_expiration_in_d
    valid = password_expiration_in_d.blank? || password_expiration_in_d > 0 && password_expiration_in_d < 366
    errors.add(:password_expiration_in_d, 'must be greater than 0 and lower than 366') unless valid
  end

  def validate_for_signup(errors, user)
    validate_seats(user, errors)

    if !valid_disk_quota?(user.quota_in_bytes.to_i)
      errors.add(:quota_in_bytes, "not enough disk quota")
    end
  end

  def validate_seats(user, errors)
    if user.builder? && !valid_builder_seats?([user])
      errors.add(:organization, "not enough seats")
    end

    if user.viewer? && remaining_viewer_seats(excluded_users: [user]) <= 0
      errors.add(:organization, "not enough viewer seats")
    end
  end

  def before_validation
    self.geocoding_quota ||= DEFAULT_GEOCODING_QUOTA
    self.here_isolines_quota ||= DEFAULT_HERE_ISOLINES_QUOTA
    self.obs_snapshot_quota ||= DEFAULT_OBS_SNAPSHOT_QUOTA
    self.obs_general_quota ||= DEFAULT_OBS_GENERAL_QUOTA
    self.mapzen_routing_quota ||= DEFAULT_MAPZEN_ROUTING_QUOTA
  end

  def before_save
    super
    @geocoding_quota_modified = changed_columns.include?(:geocoding_quota)
    @here_isolines_quota_modified = changed_columns.include?(:here_isolines_quota)
    @obs_snapshot_quota_modified = changed_columns.include?(:obs_snapshot_quota)
    @obs_general_quota_modified = changed_columns.include?(:obs_general_quota)
    @mapzen_routing_quota_modified = changed_columns.include?(:mapzen_routing_quota)
    self.updated_at = Time.now
    raise errors.join('; ') unless valid?
  end

  def before_destroy
    return false unless destroy_assets
    destroy_groups
  end

  def after_create
    super
    save_metadata
  end

  def after_save
    super
    save_metadata
  end

  def after_destroy
    super
    destroy_metadata
  end

  # INFO: replacement for destroy because destroying owner triggers
  # organization destroy
  def destroy_cascade(delete_in_central: false)
    # This remains commented because we consider that enabling this for users at SaaS is unnecessary and risky.
    # Nevertheless, code remains, _just in case_. More info at https://github.com/CartoDB/cartodb/issues/12049
    # Central branch: 1764-Allow_updating_inactive_users
    # Central asks for usage information before deleting, so organization must be first deleted there
    # Corollary: you need multithreading for organization to work if you run Central
    # self.delete_in_central if delete_in_central

    destroy_groups
    destroy_non_owner_users
    if owner
      owner.sequel_user.destroy_cascade
    else
      destroy
    end
  end

  def destroy_non_owner_users
    non_owner_users.each do |user|
      user.ensure_nonviewer
      user.shared_entities.map(&:entity).uniq.each(&:delete)
      user.sequel_user.destroy_cascade
    end
  end

  # save orgs basic metadata to redis for other services (node sql api, geocoder api, etc)
  # to use
  def save_metadata
    $users_metadata.HMSET key,
      'id', id,
      'geocoding_quota', geocoding_quota,
      'here_isolines_quota', here_isolines_quota,
      'obs_snapshot_quota', obs_snapshot_quota,
      'obs_general_quota', obs_general_quota,
      'mapzen_routing_quota', mapzen_routing_quota,
      'google_maps_client_id', google_maps_key,
      'google_maps_api_key', google_maps_private_key,
      'period_end_date', period_end_date,
      'geocoder_provider', geocoder_provider,
      'isolines_provider', isolines_provider,
      'routing_provider', routing_provider
  end

  def destroy_metadata
    $users_metadata.DEL key
  end

  def require_organization_owner_presence!
    if owner.nil?
      raise Carto::Organization::OrganizationWithoutOwner.new(self)
    end
  end

  private

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

  def period_end_date
    owner ? owner.period_end_date : nil
  end

  def public_vis_count_by_type(type)
    CartoDB::Visualization::Collection.new.fetch(
        user_id:  self.users.map(&:id),
        type:     type,
        privacy:  CartoDB::Visualization::Member::PRIVACY_PUBLIC,
        per_page: CartoDB::Visualization::Collection::ALL_RECORDS
    ).count
  end

  def name_exists_in_users?
    !::User.where(username: self.name).first.nil?
  end
end
