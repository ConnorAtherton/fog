require 'fog/core/model'

module Fog
  module Compute
    class Vcloud
      class CatalogItem < Model
        identity :href, :aliases => :Href
        ignore_attributes :xmlns, :xmlns_i, :xmlns_xsi, :xmlns_xsd

        attribute :type
        attribute :id
        attribute :name
        attribute :description, :aliases => :Description
        attribute :vapp_template_id

        def instantiate(vapp_name, options = {})
          response = service.instantiate_vapp_template(vapp_name, id, options)
          binding.pry
        end

        def customization_options
          load_unless_loaded!
          if data = service.get_customization_options( link[:href] ).body
            data.delete_if { |key, value| [:xmlns_i, :xmlns].include?(key) }
            data
          else
            nil
          end
        end

        def password_enabled?
          load_unless_loaded!
          customization_options = service.get_vapp_template(self.entity[:href]).body[:Children][:Vm][:GuestCustomizationSection]
          return false if customization_options[:AdminPasswordEnabled] == "false"
          return true if customization_options[:AdminPasswordEnabled] == "true" \
            and customization_options[:AdminPasswordAuto] == "false" \
            and ( options[:password].nil? or options[:password].empty? )
        end
      end
    end
  end
end
