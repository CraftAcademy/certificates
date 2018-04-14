require 'csv'

module CSVParse
  def self.import(file, obj, parent)
    csv_import_opts = {
      col_sep: ';',
      converters: :all,
      encoding: 'UTF-8',
      headers: true,
      header_converters: :symbol,
      quote_char: '"',
      row_sep: :auto
    }

    import = CSV.read(file, csv_import_opts).collect do |row|
      Hash[row.collect { |c, r| [c, r] }]
    end

    create_instance(parent, obj, import)
  end

  def self.create_instance(parent, obj, dataset)
    dataset.each do |data|
      student = obj.first_or_create(
        { full_name: data[:full_name] },
        full_name: data[:full_name],
        email: data[:email],
        completed: data[:completed]
      )

      binding.pry
      student.deliveries << parent unless student.deliveries.include? parent
      student.save
    end
  end
end
