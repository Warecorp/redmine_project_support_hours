include AdminHelper

class ProjectSupportHoursController < ApplicationController

  before_filter :require_admin

  accept_api_auth :index

  def index
    @status = params[:status] ? params[:status].to_i : 1
    condition = @status == 0 ? ["status <> 0"] : ["status = ?", @status]

    unless params[:name].blank?
      name = "%#{params[:name].strip.downcase}%"
      c = ["LOWER(identifier) LIKE ? OR LOWER(name) LIKE ?", name, name]
      condition.first << " AND (#{c.first})"
      condition += c[1..-1]
    end

    @projects = Project.find :all, :order => 'lft', :conditions => condition
    respond_to do |format|
      format.html { render :action => "projects", :layout => false if request.xhr? }
      format.csv  { send_data(ProjectSupportHoursHelper.projects_to_csv(@projects), :type => 'text/csv; header=present', :filename => 'export.csv') }
      format.json { render json: { projects_support_hours: ProjectSupportHoursHelper.projects_to_json(@projects) } }
    end
  end

end


