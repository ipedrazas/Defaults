package models

import (
	"crypto/sha256"
	"database/sql"
	"fmt"
	"time"

	"github.com/google/uuid"
)

type User struct {
	ID       string    `json:"user_id"`
	Username string    `json:"username"`
	Email    string    `json:"email"`
	Password string    `json:"password"`
	Avatar   string    `json:"avatar"`
	IsOnline bool      `json:"is_online"`
	Created  time.Time `json:"created"`
	Updated  time.Time `json:"updated"`
}

func GenerateID() string {
	return uuid.New().String()
}

func (u *User) Create(db *sql.DB) error {
	uid := GenerateID()
	pwd := u.SaltPassword(u.Password)
	u.ID = uid
	now := time.Now()
	_, err := db.Exec("INSERT INTO users(id, username, email, password, avatar, is_online, created, updated) VALUES(?,?,?,?,?,?,?,?);", uid, u.Username, u.Email, pwd, u.Avatar, false, now, now)
	if err != nil {
		fmt.Println(err)
		return err
	}
	u.Password = ""
	return nil
}

func (u *User) SaltPassword(pwd string) string {
	pwd = pwd + u.Email
	h := sha256.New()
	h.Write([]byte(pwd))
	bs := h.Sum(nil)
	return string(bs)

}

func GetUserByID(db *sql.DB, id string) (*User, error) {

	rows, err := db.Query("SELECT id, username, email, avatar, is_online, created, updated  FROM users WHERE id = ?;", id)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var user User
	for rows.Next() {
		err := rows.Scan(&user.ID, &user.Username, &user.Email, &user.Avatar, &user.IsOnline, &user.Created, &user.Updated)
		if err != nil {
			return nil, err
		}
	}
	err = rows.Err()

	if err != nil {
		return nil, err
	}

	return &user, nil
}

func GetAllUsers(db *sql.DB) ([]*User, error) {
	rows, err := db.Query("SELECT id, username, email, avatar, is_online, created, updated FROM users;")
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var users []*User
	for rows.Next() {
		var user User
		err := rows.Scan(&user.ID, &user.Username, &user.Email, &user.Avatar, &user.IsOnline, &user.Created, &user.Updated)
		if err != nil {
			return nil, err
		}
		users = append(users, &user)
	}
	err = rows.Err()

	if err != nil {
		return nil, err
	}

	return users, nil
}

func (u *User) SetStatus(db *sql.DB, status bool) error {
	now := time.Now()
	tx, err := db.Begin()

	if err != nil {
		return err
	}
	fmt.Println("status", status)

	stmt, err := tx.Prepare("UPDATE users SET updated = ?, is_online = ?  WHERE id = ?")

	if err != nil {
		return err
	}

	defer stmt.Close()

	_, err = stmt.Exec(now, status, u.ID)

	if err != nil {
		return err
	}

	tx.Commit()

	return nil
}
