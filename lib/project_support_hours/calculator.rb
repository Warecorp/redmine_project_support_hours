module ProjectSupportHours
  class Calculator
    # Gets the start_date for the project if set
    def self.start_date_for(project)
      start_date_field = project.custom_value_for(ProjectSupportHours::Mapper.start_date)
      start_date_field ? start_date_field.value : nil
    end

    # Gets the end_date for the project if set
    def self.end_date_for(project)
      end_date_field = project.custom_value_for(ProjectSupportHours::Mapper.end_date)
      end_date_field ? end_date_field.value : nil
    end

    # Gets the total support hours for the project if set
    def self.total_support_hours_for(project)
      t_m_field = project.custom_value_for(ProjectSupportHours::Mapper.t_m)
      return 'T&M' if !t_m_field.nil? && t_m_field.value == '1'

      hours_field = project.custom_value_for(ProjectSupportHours::Mapper.hours)
      hours_field ? hours_field.value.to_f.round(2) : 0.0
    end

    def self.total_hours_used_for(project)
      if Setting.plugin_redmine_project_support_hours['excluded_activities'].blank?
        project.time_entries.sum('hours')
      else
        project.time_entries.sum('hours', :conditions => ["activity_id NOT IN (?)",
                                                        Setting.plugin_redmine_project_support_hours['excluded_activities']])
      end
    end

    def self.total_hours_remaining_for(project)
      total_hours = total_support_hours_for(project)
      return 'T&M' if total_hours.is_a?(String)
      if total_hours and total_hours > 0
        total_hours - total_hours_used_for(project)
      else
        nil
      end.to_f.round(2)
    end

    def self.field_list_for(project)
      CustomValue.find(:first, :conditions => ["custom_field_id = ? AND customized_id = ?", ProjectSupportHours::Mapper.field_list, project.id]).to_s
    end

    def self.field_list_name_for
      field_list_field = ProjectSupportHours::Mapper.field_list.to_i
      if field_list_field != 0
        ProjectCustomField.find(ProjectSupportHours::Mapper.field_list.to_i).name.to_s
      else
        nil
      end
    end

    def self.project_role_for(project)
      pm_role_id = ProjectSupportHours::Mapper.project_role
      member = project.users_by_role[Role.find(pm_role_id)].try(:first)
      member.name if member
    end

    def self.project_role_name_for
      project_role = ProjectSupportHours::Mapper.project_role.to_i
      if project_role != 0
        Role.find(ProjectSupportHours::Mapper.project_role.to_i).name.to_s
      else
        nil
      end
    end
  end
end
