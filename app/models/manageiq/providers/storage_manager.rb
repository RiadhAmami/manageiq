module ManageIQ::Providers
  class StorageManager < ManageIQ::Providers::BaseManager
    include SupportsFeatureMixin
    supports_not :block_storage
    supports_not :cinder_volume_types
    supports_not :cloud_object_store_container_clear
    supports_not :cloud_object_store_container_create
    supports_not :cloud_volume
    supports_not :cloud_volume_create
    supports_not :ems_storage_new
    supports_not :object_storage
    supports_not :smartstate_analysis
    supports_not :storage_services
    supports_not :volume_multiattachment
    supports_not :volume_resizing

    has_many :cloud_tenants, :foreign_key => :ems_id, :dependent => :destroy
    has_many :volume_availability_zones, :class_name => "AvailabilityZone", :foreign_key => :ems_id, :dependent => :destroy

    has_many :cloud_volumes, :foreign_key => :ems_id, :dependent => :destroy
    has_many :physical_storages, :foreign_key => "ems_id", :dependent => :destroy,
             :inverse_of => :ext_management_system
    has_many :storage_resources, :foreign_key => "ems_id", :dependent => :destroy,
             :inverse_of => :ext_management_system
    has_many :host_initiators, :foreign_key => "ems_id", :dependent => :destroy,
             :inverse_of => :ext_management_system
    has_many :host_initiator_groups, :foreign_key => "ems_id", :dependent => :destroy,
             :inverse_of => :ext_management_system
    has_many :volume_mappings, :foreign_key => "ems_id", :dependent => :destroy,
             :inverse_of => :ext_management_system
    has_many :san_addresses, :foreign_key => "ems_id", :dependent => :destroy,
             :inverse_of => :ext_management_system
    has_many :physical_storage_families, :foreign_key => :ems_id, :dependent => :destroy,
             :inverse_of => :ext_management_system
    has_many :storage_services, :foreign_key => "ems_id", :dependent => :destroy,
             :inverse_of => :ext_management_system
    has_many :storage_service_resource_attachments, :foreign_key => "ems_id",
             :dependent => :destroy, :inverse_of => :ext_management_system

    has_many :cloud_volume_snapshots, :foreign_key => :ems_id, :dependent => :destroy
    has_many :cloud_volume_backups,   :foreign_key => :ems_id, :dependent => :destroy
    has_many :cloud_volume_types,     :foreign_key => :ems_id, :dependent => :destroy

    has_many :cloud_object_store_containers, :foreign_key => :ems_id, :dependent => :destroy
    has_many :cloud_object_store_objects,    :foreign_key => :ems_id

    has_many :wwpn_candidates, :foreign_key => :ems_id, :dependent => :destroy,
             :inverse_of => :ext_management_system

    belongs_to :parent_manager,
               :foreign_key => :parent_ems_id,
               :class_name  => "ManageIQ::Providers::BaseManager",
               :autosave    => true

    delegate :queue_name_for_ems_refresh, :to => :parent_manager

    def self.display_name(number = 1)
      n_('Storage Manager', 'Storage Managers', number)
    end

    class << model_name
      define_method(:route_key) { "ems_storages" }
      define_method(:singular_route_key) { "ems_storage" }
    end

    # Allow only adding supported types. Non-supported types for adding will not be visible in the Type field
    def self.supported_types_and_descriptions_hash
      supported_subclasses.select { |k| k.supports?(:ems_storage_new) }.each_with_object({}) do |klass, hash|
        hash[klass.ems_type] = klass.description
      end
    end
  end
end
