module Carto
  module OrganizationCommons

    class OrganizationWithoutOwner < StandardError

      attr_reader :organization

      def initialize(organization)
        @organization = organization
        super 'Organization has no owner'
      end

    end

    # create the key that is used in redis
    def key
      "rails:orgs:#{name}"
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

    def period_end_date
      owner&.period_end_date
    end

  end
end

module Carto::OrganizationSoftLimits
  def soft_geocoding_limit?
    owner.try(:soft_geocoding_limit)
  end

  def soft_twitter_datasource_limit?
    owner.try(:soft_twitter_datasource_limit)
  end

  def soft_here_isolines_limit?
    owner.try(:soft_here_isolines_limit)
  end

  def soft_obs_snapshot_limit?
    owner.try(:soft_obs_snapshot_limit)
  end

  def soft_obs_general_limit?
    owner.try(:soft_obs_general_limit)
  end

  def soft_mapzen_routing_limit?
    owner.try(:soft_mapzen_routing_limit)
  end

  def db_size_in_bytes
    users.map(&:db_size_in_bytes).sum
  end

end
