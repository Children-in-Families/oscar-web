require "active_record/connection_adapters/abstract/schema_definitions"
module CustomSchemaDumper
  private

  def indexes_in_create(table, stream)
    if (indexes = @connection.indexes(table)).any?
      index_statements = indexes.map do |index|
        "    t.index #{index_parts(index).join(', ')}"
      end.uniq
      stream.puts index_statements.sort.join("\n")
    end
  end

  def tables(stream)
    sorted_tables = @connection.tables.sort

    sorted_tables.uniq.each do |table_name|
      table(table_name, stream) unless ignored?(table_name)
    end

    # dump foreign keys at the end to make sure all dependent tables exist.
    if @connection.supports_foreign_keys?
      sorted_tables.uniq.each do |tbl|
        foreign_keys(tbl, stream) unless ignored?(tbl)
      end
    end
  end

  def foreign_keys(table, stream)
    if (foreign_keys = @connection.foreign_keys(table)).any?
      add_foreign_key_statements = foreign_keys.reject{|foreign_key| foreign_key.to_table.include?('.') }.map do |foreign_key|
        parts = [
          "add_foreign_key #{remove_prefix_and_suffix(foreign_key.from_table).inspect}",
          remove_prefix_and_suffix(foreign_key.to_table).inspect,
        ]

        if foreign_key.column != @connection.foreign_key_column_for(foreign_key.to_table)
          parts << "column: #{foreign_key.column.inspect}"
        end

        if foreign_key.custom_primary_key?
          parts << "primary_key: #{foreign_key.primary_key.inspect}"
        end

        if foreign_key.name !~ /^fk_rails_[0-9a-f]{10}$/
          parts << "name: #{foreign_key.name.inspect}"
        end

        parts << "on_update: #{foreign_key.on_update.inspect}" if foreign_key.on_update
        parts << "on_delete: #{foreign_key.on_delete.inspect}" if foreign_key.on_delete

        "  #{parts.join(', ')}"
      end

      stream.puts add_foreign_key_statements.sort.join("\n")
    end
  end
end
