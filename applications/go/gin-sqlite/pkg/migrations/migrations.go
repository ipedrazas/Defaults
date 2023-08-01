package migrations

import "database/sql"

const createUsersTable string = `
CREATE TABLE IF NOT EXISTS users (
id string NOT NULL PRIMARY KEY,
created DATE NULL,
updated DATE NULL,
username TEXT NOT NULL,
email TEXT NOT NULL,
password TEXT NOT NULL,
avatar TEXT NULL,
is_online BOOLEAN not null default false
);`

func CreateTables(db *sql.DB) error {
	if _, err := db.Exec(createUsersTable); err != nil {
		return err
	}
	return nil
}
