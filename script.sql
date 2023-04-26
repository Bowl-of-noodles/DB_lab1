\prompt 'Введите название схемы: ' schema_name
set myvars.sch to :'schema_name';

\prompt 'Введите название таблицы: ' table_name
set myvars.tbl to :'table_name';
do

$$

    declare

        table_id       oid;
        schema_id	oid;
        
	input		text;
	table_name	text; 
	schema_name	text;
	db_name	text;
 
        my_column_name text;
	column_record  record;
        column_number  int2vector;
        trigger_name   text;
        result         text;

    begin

	input  = CAST(current_setting('myvars.sch') AS text);
	
	if(input LIKE '%.%.%') then
		RAISE EXCEPTION 'Input must include schema name or database.schema name' ;
	elsif (input LIKE '%.%') then
		if (input LIKE '\*.%') then
			db_name = null;
			schema_name = split_part(input, '.', 2);
		else
			db_name = split_part(input, '.', 1);
			schema_name = split_part(input, '.', 2);
		end if;
	else
		schema_name = input;			
	end if;
	
	table_name  = CAST(current_setting('myvars.tbl') AS text);
	
	if(table_name LIKE '%.%' or input LIKE '%,%') then
		RAISE EXCEPTION 'Input must include only table name' ;
	end if;
	
	if (db_name) is not null then
		if 1 != (select count(*) from pg_catalog.pg_database where datname = db_name) then
			RAISE EXCEPTION 'Cannot access this database, currently working with studs database';
		end if;
	end if;

 	select "oid" into schema_id from pg_catalog.pg_namespace where "nspname" = CAST(schema_name AS name);
 	if (schema_id) is null then

            raise 'Cannot find table with this schema: %', schema_name;
       else     
      
		select "oid" into table_id from pg_catalog.pg_class where "relnamespace" = schema_id AND "relname" = CAST(table_name AS name);
		
		
		if (table_id) is null then

		    raise 'Cannot find table with this name: %', table_name;

		else

		    raise notice 'Таблица: %', table_name;

		    raise notice 'Имя столбца    Имя триггера';

		    raise notice '-------------- ----------------';

		    for column_record in select * from pg_catalog.pg_attribute where attrelid = table_id

		        loop

		            if column_record.attnum > 0 then

		                column_number = column_record.attnum;

		                my_column_name = column_record.attname;

		                select ARRAY (select tgname from studs.pg_catalog.pg_trigger where tgrelid = table_id AND 
					      (column_record.attnum = any(tgattr))) into trigger_name;

		                if trigger_name is null then

		                    continue;

		                end if;

		                select format('%-15s %-15s', my_column_name, trigger_name)

		                into result;

		                raise notice '%', result;

		            end if;

		        end loop;

		end if;
	end if;
    end;

$$ LANGUAGE plpgsql;
