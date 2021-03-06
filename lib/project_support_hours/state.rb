module ProjectSupportHours
  class State

    class << self
      attr_reader :range_1, :range_2, :range_3, :range_4

      def calculate(start_date, end_date, total_support_hours, total_hours_used)
        start_date -= 1.day if start_date == end_date
        optimum = optimum_time_per_day(start_date, end_date, total_support_hours)

        if optimum < 0
          return 'green' if total_hours_used <= total_support_hours
          return 'red' if total_hours_used > total_support_hours
        end

        state = (total_hours_used.to_f / optimum)
        mapping_ranges

        return 'red' if state > range_4 || state < range_1
        return 'yellow' if (range_1 < state and state < range_2) ||
          (range_3 < state and state < range_4)

        'green'
      end

      def optimum_time_per_day(start_date, end_date, total_support_hours)
        diff = total_support_hours / total_days(start_date, end_date).to_f
        date_now = Date.current > end_date ? end_date : Date.current
        days = ProjectSupportHoursHelper.work_days_beetwen(start_date, date_now)
        days * diff.to_f
      end

      def total_days(start_date, end_date)
        ProjectSupportHoursHelper.work_days_beetwen(start_date, end_date)
      end

      def remaining_days end_date
        ProjectSupportHoursHelper.work_days_beetwen(Date.current, end_date)
      end

      def mapping_ranges
        mapper = ProjectSupportHours::Mapper
        @range_1, @range_2, @range_3, @range_4 =
          mapper.range_1, mapper.range_2, mapper.range_3, mapper.range_4
      end

    end
  end
end
