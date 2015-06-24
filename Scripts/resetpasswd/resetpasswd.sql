-- Reset the password and update profile to RegisteredUser for all users who
-- have not changed their password in the last x days and return their rows
-- from the users table
WITH need_reset AS
    (SELECT id
     FROM public.users
     WHERE id NOT IN
             (SELECT DISTINCT (row_data->'id')::int AS userid
                FROM audit.logged_actions
                WHERE SCHEMA_NAME = 'public'
                    AND TABLE_NAME = 'users'
                    AND action_tstamp_tx > CURRENT_TIMESTAMP - INTERVAL '%(num_days)s' DAY
                    AND ((action = 'U' AND changed_fields ? 'password') OR action = 'I')
                ORDER BY userid)
     ORDER BY id),
disabled AS
    (UPDATE public.users
        SET profile = 'RegisteredUser', password = rpad('', 80, 'a')
        WHERE id IN
                (SELECT id
                FROM need_reset) RETURNING *)
SELECT * FROM disabled;
