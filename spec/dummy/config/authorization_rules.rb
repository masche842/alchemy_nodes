authorization do
  role :admin do
    has_permission_on :products, :to => [:manage]
    has_permission_on :admin_products, :to => [:manage]
  end

  role :guest do
    has_permission_on :products, :to  => [:index, :show]
  end
end