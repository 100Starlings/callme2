ActiveAdmin.register Agent do

  config.filters = false

  batch_action :go_on_call do |selection|
    Agent.find(selection).each do |agent|
      agent.on_call!
    end
    redirect_to :back
  end

  batch_action :go_off_call do |selection|
    Agent.find(selection).each do |agent|
      agent.off_call!
    end
    redirect_to :back
  end

  index do
    selectable_column
    column :name, :sortable => :name do |agent|
      link_to agent.name, [:admin, agent]
    end
    column :on_call, :sortable => :on_call
    column :devices do |agent|
      ul do
        agent.devices.each do |device|
          li device.to_s
        end
      end
    end
    actions defaults: false do |agent|
      if agent.off_call?
        link_to "Go On Call", [:on_call_admin, agent], method: :put
      end
    end
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

  member_action :on_call, :method => :put do
    Agent.all.each(&:off_call!)
    agent = Agent.find(params[:id])
    agent.on_call!
    redirect_to admin_agents_path, { notice: "Agent #{agent.name} is now on call!" }
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