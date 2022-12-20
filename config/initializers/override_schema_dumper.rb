require 'custom_schema_dumper'

ActiveRecord::SchemaDumper.send :prepend, CustomSchemaDumper

