package main

import (
	"fmt"
	"log"
	"net/http"
)

var (
	version   string
	buildDate string
	// In-memory map to store shortened URLs
	urlStore = make(map[string]string)
)

func main() {
	// Display version info on startup
	fmt.Printf("Version: %s\nBuild Date: %s\n", version, buildDate)

	// Setup routes
	http.HandleFunc("/", redirectHandler)
	http.HandleFunc("/shorten", shortenHandler)

	// Start HTTP server
	fmt.Println("Starting server on :8080")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatalf("Server failed: %v", err)
	}
}

// redirectHandler redirects from short URL to the original URL
func redirectHandler(w http.ResponseWriter, r *http.Request) {
	shortURL := r.URL.Path[1:] // Remove leading "/"
	if originalURL, ok := urlStore[shortURL]; ok {
		http.Redirect(w, r, originalURL, http.StatusFound)
	} else {
		http.NotFound(w, r)
	}
}

// shortenHandler shortens a given URL and stores it in the map
func shortenHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
		return
	}

	originalURL := r.FormValue("url")
	if originalURL == "" {
		http.Error(w, "URL is required", http.StatusBadRequest)
		return
	}

	// For simplicity, we just use the length of the map as the short URL key
	shortURL := fmt.Sprintf("%d", len(urlStore)+1)
	urlStore[shortURL] = originalURL

	// Return the shortened URL
	fmt.Fprintf(w, "Shortened URL: http://localhost:8080/%s\n", shortURL)
}
