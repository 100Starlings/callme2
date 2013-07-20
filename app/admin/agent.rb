ActiveAdmin.register Agent do

  config.filters = false

  batch_action :go_on_call do |selection|
    Agent.find(selection).each do |agent|
      agent.on_call!
    end
  end

  batch_action :go_off_call do |selection|
    Agent.find(selection).each do |agent|
      agent.off_call!
    end
  end

  index do
    column :name, :sortable => :name do |agent|
      link_to agent.name, [:admin, agent]
    end
    column :on_call, :sortable => :on_call
  end

  show do |agent|
    attributes_table do
      row :name
      row :on_call
      agent.devices.each do |device|
        row device.name do
          device.address
        end
      end

    end
    active_admin_comments
  end
  controller do
    def permitted_params
      params.permit(agent: [:name, :on_call, { devices_attributes: [:name, :address, :id, :_destroy]}])
    end
  end

  form do |f|
    f.inputs "Details" do
      f.input :name
    end
    f.inputs "Status" do
      f.input :on_call
    end
    f.has_many :devices do |device|
      device.input :name
      device.input :address
      device.input :_destroy, as: :boolean, label: "Remove"
    end

    f.actions
  end

end
