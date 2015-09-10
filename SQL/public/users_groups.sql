-- View: users_groups

-- Comment: List of users and the groups they are members of, ordered  by surname

-- DROP VIEW users_groups;

CREATE OR REPLACE VIEW users_groups AS 
 SELECT a.username, a.surname, a.name as firstname, c.name as group 
 from users a join usergroups b on a.id=b.userid 
 join groups c on b.groupid = c.id 
 order by a.surname, a.name, c.name;

ALTER TABLE users_groups
  OWNER TO geonetwork;
COMMENT ON VIEW users_groups
  IS 'View includes all users, showing:
- Username
- Surname
- First name
- Group';
