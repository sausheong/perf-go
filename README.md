# Performance testing on a basic Go web application

Testing the performance of a simple Go web application.

Go web application code.

```go
package main

import (
  "fmt"
  "time"
  "net/http"
)

func work(w http.ResponseWriter, r *http.Request) {
  time.Sleep(500 * time.Millisecond)
  fmt.Fprintf(w, "<h1>Hello Perf</h1>")
}

func main() {
  http.HandleFunc("/perf", work)
  http.ListenAndServe("0.0.0.0:8080", nil)
}

```

Puma-Ruby web application code.

```ruby
require 'sinatra'
configure { set :port, 8080 }

get "/perf" do  
  sleep 0.5
  "<h1>Hello Perf</h1>"
end
```

### Connection rate per sec

The rate of connections being initiated per second. 

Go spins off new goroutines whenever a connection is made, so the rate of creating connections is proportionate to the rate of requests being made. 

Puma has a min of 10 threads and a max of 100 threads so the rate of creating new connections have an upper limit. When that limit is reached, the connection rate plateaus.

![](connection_rate_per_sec.png)

### Connection time average

The average lifetime for successful connections which is the time between connection initiation and the time the connection is closed. A connection is considered successful if it had at least one call that completed successfully.

Go spins off new goroutines when needed, so the average connection time remains the same.

Puma has an upper limit of 100 threads, when that limit is reached, the connection time slows and becomes proportionate the the number of requests.


![](connection_time_avg.png)

### Reply rate average

The average rate of replies from the server. 

Go spins off new goroutines when needed, so the rate of reply is consistent and remains the same throughout.

Puma has an upper limit of 100 threads, so when that limit is reached, the reply rate plateaus.

![](reply_rate_avg.png)

### Number of successful replies

The number of successful replies (2xx) from the server. 

Go and Puma both return success replies for all the requests.


![](reply_status_2xx.png)

### Reply response time

The average time for the server to respond to a request.

Go spins off new goroutines when needed, so the reply response time is consistent and remains the same throughout.

Puma has an upper limit of 100 threads, so when that limit is reached, the reply response times increases proportionately the number of requests.

![](reply_time_response.png)

### Total test duration

This is how long it took to do the test.

![](total_test_duration.png)