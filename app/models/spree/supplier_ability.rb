module Spree
  class SupplierAbility
    include CanCan::Ability

    def initialize(user)
      user ||= Spree.user_class.new

      if user.supplier
        # TODO: Want this to be inline like:
        # can [:admin, :read, :stock], Spree::Product, suppliers: { id: user.supplier_id }
        # can [:admin, :read, :stock], Spree::Product, supplier_ids: user.supplier_id
        can [:admin, :read, :stock], Spree::Product do |product|
          product.supplier_ids.include?(user.supplier_id)
        end
        can [:admin, :index, :manage, :create, :update, :edit], Spree::Product
        can [:admin, :manage], Spree::Image do |image|
          image.viewable.product.supplier_ids.include?(user.supplier_id)
        end
        can :create, Spree::Image
        can [:admin, :manage, :read, :ready, :ship], Spree::Shipment, order: { state: 'complete' }, stock_location: { supplier_id: user.supplier_id }
        can [:admin, :create, :update], :stock_items
        can [:admin, :manage, :create, :update], Spree::StockItem, stock_location_id: user.supplier.stock_locations.pluck(:id)
        can [:admin, :manage], Spree::StockLocation, supplier_id: user.supplier_id
        can :create, Spree::StockLocation
        can [:admin, :manage], Spree::StockMovement, stock_item: { stock_location_id: user.supplier.stock_locations.pluck(:id) }
        can :create, Spree::StockMovement
        can [:admin, :update], Spree::Supplier, id: user.supplier_id
      end

    end
  end
end
