module ProjectSupportHoursHelper

  include Redmine::I18n

  def self.total_support_hours(project)
    ProjectSupportHours::Calculator.total_support_hours_for(project)
  end

  def self.total_hours_used(project)
    ProjectSupportHours::Calculator.total_hours_used_for(project).to_f.round(2)
  end

  def self.total_hours_remaining(project)
    ProjectSupportHours::Calculator.total_hours_remaining_for(project)
  end

  def self.start_date(project)
    ProjectSupportHours::Calculator.start_date_for(project)
  end

  def self.end_date(project)
    ProjectSupportHours::Calculator.end_date_for(project)
  end

  def self.field_list(project)
    ProjectSupportHours::Calculator.field_list_for(project)
  end

  def self.field_list_name
    ProjectSupportHours::Calculator.field_list_name_for
  end

  def self.project_role(project)
    ProjectSupportHours::Calculator.project_role_for(project)
  end

  def self.project_role_name
    ProjectSupportHours::Calculator.project_role_name_for
  end

  def self.projects_to_csv(projects)
      ic = Iconv.new(l(:general_csv_encoding), 'UTF-8')
      decimal_separator = l(:general_csv_decimal_separator)
      export = FCSV.generate(:col_sep => l(:general_csv_separator)) do |csv|
          # csv header fields
          headers = [l(:label_project),
                     l(:project_support_hours_total_hours_field_label),
                     l(:label_spent_time),
                     l(:project_support_hours_remaining_hours_field_label),
                     l(:project_support_hours_start_date_field_label),
                     l(:project_support_hours_end_date_field_label),
                     field_list_name,
                     project_role_name,
                     ]

          csv << headers.collect {|c| begin; ic.iconv(c.to_s); rescue; c.to_s; end }
          # csv lines
          projects.each do |project|
              fields = [project.name,
                        total_support_hours(project),
                        total_hours_used(project),
                        total_hours_remaining(project),
                        start_date(project),
                        end_date(project),
                        field_list(project),
                        project_role(project),
                        ]

            csv << fields.collect {|c| begin; ic.iconv(c.to_s); rescue; c.to_s; end }
          end
      end
      export
  end

  def self.project_state(start_date, end_date, total_support_hours, total_hours_used)
    return if (total_support_hours == 'T&M' || start_date.blank? || end_date.blank? || total_support_hours == 0.0)
    ProjectSupportHours::State.calculate(start_date.to_date, end_date.to_date, total_support_hours, total_hours_used)
  end

  def self.days_left end_date
    return if end_date.blank?
    end_date = end_date.to_date
    return 'is over' if Date.current > end_date
    days_count = end_date - Date.current
    "#{days_count} #{'day'.pluralize(days_count)} left"
  end

end
