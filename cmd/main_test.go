package main

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

// TestShortenHandler tests the shortenHandler function
func TestShortenHandler(t *testing.T) {
	// Set up an HTTP POST request with a URL to shorten
	reqBody := strings.NewReader("url=https://example.com")
	req := httptest.NewRequest(http.MethodPost, "/shorten", reqBody)

	// Record the response
	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(shortenHandler)

	// Call the handler function
	handler.ServeHTTP(rr, req)

	// Check that the status code is 200 OK
	if status := rr.Code; status != http.StatusOK {
		t.Errorf(
			"handler returned wrong status code: got %v want %v",
			status,
			http.StatusOK,
		)
	}

	// Check that the response body contains the shortened URL
	expected := "Shortened URL: http://localhost:8080/1"
	if !strings.Contains(rr.Body.String(), expected) {
		t.Errorf(
			"handler returned unexpected body: got %v want %v",
			rr.Body.String(),
			expected,
		)
	}

	// Check if the URL was stored correctly in the map
	if urlStore["1"] != "https://example.com" {
		t.Errorf("URL was not stored correctly, got: %v", urlStore["1"])
	}
}
