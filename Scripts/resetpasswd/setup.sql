-- Ensure the GeoNetwork users table is audited
SELECT audit.audit_table('public.users');

-- Define a trigger to ensure a user has the highest profile assigned when they
-- change their password from the default reset password

CREATE OR REPLACE FUNCTION public.users_password_change_update_profile() RETURNS TRIGGER AS $function$
BEGIN
IF OLD.password = rpad('', 80, 'a') AND NEW.password <> rpad('', 80, 'a') THEN
    NEW.profile := (SELECT profile
                    FROM
                        (SELECT event_id,
                            row_data,
                            changed_fields,
                            CASE
                                WHEN changed_fields ? 'password' AND changed_fields->'password' = rpad('', 80, 'a') THEN
                                    row_data->'profile'
                                WHEN changed_fields ? 'profile' THEN
                                    changed_fields->'profile'
                                ELSE
                                    row_data->'profile'
                            END AS profile
                        FROM audit.logged_actions
                        WHERE SCHEMA_NAME = 'public'
                            AND TABLE_NAME = 'users'
                            AND (row_data->'id')::int = NEW.id
                            AND NOT (row_data->'password' = rpad('', 80, 'a') AND NOT changed_fields ? 'profile')
                        ORDER BY event_id desc) AS a LIMIT 1);
END IF;
RETURN NEW;
END;
$function$ LANGUAGE plpgsql;
COMMENT ON FUNCTION public.users_password_change_update_profile() IS $comment$
Trigger function to ensure that if a users password is being changed from the
default reset password then ensure the users profile is restored to it's
correct value
$comment$;

DROP TRIGGER IF EXISTS users_password_change ON users;
CREATE TRIGGER users_password_change
BEFORE UPDATE OF password ON public.users
FOR EACH ROW
EXECUTE PROCEDURE public.users_password_change_update_profile();
