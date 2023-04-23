\prompt 'Введите название таблицы: ' table_name
set myvars.tbl to :table_name;

do
$$

    declare

        column_record  record;

        table_id       oid;

        my_column_name text;

        column_number  int2vector;

        trigger_name   text;

        result         text;

    begin

        select "oid" into table_id from pg_catalog.pg_class where "relname" = CAST(current_setting('myvars.tbl') AS name);

        if (table_id) is null then

            raise 'Cannot find table with this name';

        else

            raise notice 'Таблица: %', current_setting('myvars.tbl');

            raise notice 'Имя столбца    Имя триггера';

            raise notice '-------------- ----------------';

            for column_record in select * from pg_catalog.pg_attribute where attrelid = table_id

                loop

                    if column_record.attnum > 0 then

                        column_number = column_record.attnum;

                        my_column_name = column_record.attname;

                        select tgname into trigger_name from pg_catalog.pg_trigger where tgattr = column_number;

                        if trigger_name is null then

                            continue;

                        end if;

                        select format('%-15s %-15s', my_column_name, trigger_name)

                        into result;

                        raise notice '%', result;

                    end if;

                end loop;

        end if;

    end;

$$ LANGUAGE plpgsql;
