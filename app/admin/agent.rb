ActiveAdmin.register Agent do
  config.filters = false

  index do
    selectable_column
    column :name, sortable: :name do |agent|
      link_to agent.name, [:admin, agent]
    end
    column :on_call_level, sortable: :on_call_level
  end

  show do |_agent|
    attributes_table do
      row :name
      row :email
      row :pagerduty_id
      row :on_call_level
      row :contact_number
    end
    active_admin_comments
  end

  controller do
    def permitted_params
      params.permit(agent:
        [
          :name,
          :email,
          :on_call_level,
        ])
    end
  end

  form do |f|
    f.inputs "Details" do
      f.input :name
      f.input :email
    end
    f.inputs "Status" do
      f.input :on_call_level
    end

    f.actions
  end
end
