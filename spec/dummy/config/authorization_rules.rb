authorization do
  role :admin do
    has_permission_on :products, :to => [:manage]
    has_permission_on :admin_products, :to => [:manage]

    has_permission_on :alchemy_nodes_admin_nodes, :to => [:manage, :manage_nodes, :edit_node_content]
  end

  role :guest do
    has_permission_on :products, :to  => [:index, :show]
  end
end

privileges do

  privilege :manage_nodes, :alchemy_nodes_admin_nodes do
    includes :manage, :switch_language, :sort, :order, :configure, :flush, :copy, :copy_language_tree
  end

  privilege :edit_node_content, :alchemy_nodes_admin_nodes do
    includes :edit, :unlock, :show, :publish, :visit
  end

end