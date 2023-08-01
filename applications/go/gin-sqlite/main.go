package main

import (
	"context"
	"database/sql"
	"fmt"
	"httpusers/pkg/migrations"
	"httpusers/pkg/models"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	_ "github.com/mattn/go-sqlite3"
)

var (
	DB     *sql.DB
	dbFile string = "httpd.db"
)

func main() {
	if os.Getenv("DBFILE") != "" {
		dbFile = os.Getenv("DBFILE")
	}
	fmt.Println("DBFILE: ", dbFile)

	db, err := sql.Open("sqlite3", dbFile)
	if err != nil {
		log.Fatal(err)
	}

	DB = db
	defer DB.Close()

	migrations.CreateTables(DB)

	port := "7870"

	if os.Getenv("PORT") != "" {
		port = os.Getenv("PORT")
	}

	router := GinRouter()

	server := &http.Server{
		Addr:           ":" + port,
		Handler:        router,
		ReadTimeout:    30 * time.Second,
		WriteTimeout:   30 * time.Second,
		MaxHeaderBytes: 1 << 20,
	}

	go func() {
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("listen: %s\n", err)
		}
	}()

	// Wait for interrupt signal to gracefully shutdown the server with
	// a timeout of 5 seconds.
	quit := make(chan os.Signal, 1)
	// kill (no param) default send syscall.SIGTERM
	// kill -2 is syscall.SIGINT
	// kill -9 is syscall.SIGKILL but can't be catch, so don't need add it
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	log.Println("Shutting down http server...")

	// The context is used to inform the server it has 5 seconds to finish
	// the request it is currently handling
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	if err := server.Shutdown(ctx); err != nil {
		log.Fatal("Server forced to shutdown: ", err)
	}

	log.Println("Server exiting")
}

func GinRouter() *gin.Engine {
	router := gin.New()

	// Set a lower memory limit for multipart forms
	router.MaxMultipartMemory = 100 << 20 // 100 MB

	// Custom Logger
	router.Use(gin.LoggerWithFormatter(func(param gin.LogFormatterParams) string {
		return fmt.Sprintf("%s |%s %d %s| %s |%s %s %s %s | %s | %s | %s\n",
			param.TimeStamp.Format(time.RFC1123),
			param.StatusCodeColor(),
			param.StatusCode,
			param.ResetColor(),
			param.ClientIP,
			param.MethodColor(),
			param.Method,
			param.ResetColor(),
			param.Path,
			param.Latency,
			param.Request.UserAgent(),
			param.ErrorMessage,
		)
	}))
	router.Use(cors.Default())

	// Recovery middleware recovers from any panics and writes a 500 if there was one.
	router.Use(gin.Recovery())

	router.Use(gin.Logger())

	api := router.Group("/api/v1")
	users := api.Group("/users")
	{
		users.POST("", AddUser)
		users.GET(":userid", GetUserByID)
		users.GET("", GetAllUsers)
		users.POST(":userid/:status", SetStatus)

	}

	return router
}

func AddUser(c *gin.Context) {
	var user models.User
	if err := c.BindJSON(&user); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	if err := user.Create(DB); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, user)
}

func GetUserByID(c *gin.Context) {
	id := c.Param("userid")
	user, err := models.GetUserByID(DB, id)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, user)
}

func GetAllUsers(c *gin.Context) {
	users, err := models.GetAllUsers(DB)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, users)
}

func SetStatus(c *gin.Context) {
	id := c.Param("userid")
	status := c.Param("status")
	stt := status == "online"
	user := models.User{ID: id}
	if err := user.SetStatus(DB, stt); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, status)
}
