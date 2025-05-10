#!/bin/bash

# Check if log file is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <log_file>"
    exit 1
fi

LOG_FILE="$1"
REPORT_FILE="log_analysis_output.txt"

# Check if log file exists
if [ ! -f "$LOG_FILE" ]; then
    echo "Error: Log file '$LOG_FILE' not found."
    exit 1
fi

# Initialize report file
echo "Log File Analysis Report" > "$REPORT_FILE"
echo "Generated on: $(date)" >> "$REPORT_FILE"
echo "Log File: $LOG_FILE" >> "$REPORT_FILE"
echo "----------------------------------------" >> "$REPORT_FILE"

# 1. Request Counts
TOTAL_REQUESTS=$(wc -l < "$LOG_FILE")
GET_REQUESTS=$(grep -c '"GET' "$LOG_FILE")
POST_REQUESTS=$(grep -c '"POST' "$LOG_FILE")

echo "1. Request Counts" >> "$REPORT_FILE"
echo "Total Requests: $TOTAL_REQUESTS" >> "$REPORT_FILE"
echo "GET Requests: $GET_REQUESTS" >> "$REPORT_FILE"
echo "POST Requests: $POST_REQUESTS" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 2. Unique IP Addresses
echo "2. Unique IP Addresses" >> "$REPORT_FILE"
UNIQUE_IPS=$(awk '{print $1}' "$LOG_FILE" | sort | uniq)
UNIQUE_IP_COUNT=$(echo "$UNIQUE_IPS" | wc -l)
echo "Total Unique IPs: $UNIQUE_IP_COUNT" >> "$REPORT_FILE"
echo "GET and POST Requests per IP:" >> "$REPORT_FILE"
for ip in $UNIQUE_IPS; do
    IP_GET=$(grep "$ip" "$LOG_FILE" | grep -c '"GET')
    IP_POST=$(grep "$ip" "$LOG_FILE" | grep -c '"POST')
    echo "$ip - GET: $IP_GET, POST: $IP_POST" >> "$REPORT_FILE"
done
echo "" >> "$REPORT_FILE"

# 3. Failure Requests
FAILURE_REQUESTS=$(awk '$9 ~ /^[45][0-9][0-9]$/' "$LOG_FILE" | wc -l)
FAILURE_PERCENT=$(echo "scale=2; ($FAILURE_REQUESTS / $TOTAL_REQUESTS) * 100" | bc)
echo "3. Failure Requests" >> "$REPORT_FILE"
echo "Total Failed Requests (4xx, 5xx): $FAILURE_REQUESTS" >> "$REPORT_FILE"
echo "Percentage of Failed Requests: $FAILURE_PERCENT%" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 4. Top User
TOP_IP=$(awk '{print $1}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -1)
TOP_IP_COUNT=$(echo "$TOP_IP" | awk '{print $1}')
TOP_IP_ADDR=$(echo "$TOP_IP" | awk '{print $2}')
echo "4. Top User" >> "$REPORT_FILE"
echo "Most Active IP: $TOP_IP_ADDR ($TOP_IP_COUNT requests)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 5. Daily Request Averages
DAILY_COUNTS=$(awk -F'[' '{print $2}' "$LOG_FILE" | awk -F':' '{print $1}' | sort | uniq -c)
DAY_COUNT=$(echo "$DAILY_COUNTS" | wc -l)
TOTAL_DAILY_REQUESTS=$(echo "$DAILY_COUNTS" | awk '{sum += $1} END {print sum}')
AVG_DAILY_REQUESTS=$(echo "scale=2; $TOTAL_DAILY_REQUESTS / $DAY_COUNT" | bc)
echo "5. Daily Request Averages" >> "$REPORT_FILE"
echo "Average Requests per Day: $AVG_DAILY_REQUESTS" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 6. Failure Analysis
echo "6. Failure Analysis" >> "$REPORT_FILE"
FAILURE_DAYS=$(awk '$9 ~ /^[45][0-9][0-9]$/ {print $4}' "$LOG_FILE" | awk -F'[' '{print $2}' | awk -F':' '{print $1}' | sort | uniq -c | sort -nr)
echo "Days with Highest Failure Requests:" >> "$REPORT_FILE"
echo "$FAILURE_DAYS" | while read -r count day; do
    echo "$day: $count failures" >> "$REPORT_FILE"
done
echo "" >> "$REPORT_FILE"

# 7. Request by Hour
echo "7. Requests by Hour" >> "$REPORT_FILE"
HOURLY_REQUESTS=$(awk -F'[' '{print $2}' "$LOG_FILE" | awk -F':' '{print $2}' | sort | uniq -c)
echo "Requests per Hour:" >> "$REPORT_FILE"
echo "$HOURLY_REQUESTS" | while read -r count hour; do
    echo "Hour $hour: $count requests" >> "$REPORT_FILE"
done
echo "" >> "$REPORT_FILE"

# 8. Status Codes Breakdown
echo "8. Status Codes Breakdown" >> "$REPORT_FILE"
STATUS_CODES=$(awk '{print $9}' "$LOG_FILE" | sort | uniq -c | sort -nr)
echo "Status Code Frequencies:" >> "$REPORT_FILE"
echo "$STATUS_CODES" | while read -r count code; do
    echo "Status $code: $count occurrences" >> "$REPORT_FILE"
done
echo "" >> "$REPORT_FILE"

# 9. Most Active User by Method
TOP_GET_IP=$(awk '/"GET/ {print $1}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -1)
TOP_GET_COUNT=$(echo "$TOP_GET_IP" | awk '{print $1}')
TOP_GET_ADDR=$(echo "$TOP_GET_IP" | awk '{print $2}')
TOP_POST_IP=$(awk '/"POST/ {print $1}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -1)
TOP_POST_COUNT=$(echo "$TOP_POST_IP" | awk '{print $1}')
TOP_POST_ADDR=$(echo "$TOP_POST_IP" | awk '{print $2}')
echo "9. Most Active User by Method" >> "$REPORT_FILE"
echo "Most Active GET IP: $TOP_GET_ADDR ($TOP_GET_COUNT GET requests)" >> "$REPORT_FILE"
echo "Most Active POST IP: $TOP_POST_ADDR ($TOP_POST_COUNT POST requests)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 10. Patterns in Failure Requests
echo "10. Patterns in Failure Requests" >> "$REPORT_FILE"
FAILURE_HOURS=$(awk '$9 ~ /^[45][0-9][0-9]$/ {print $4}' "$LOG_FILE" | awk -F'[' '{print $2}' | awk -F':' '{print $2}' | sort | uniq -c | sort -nr)
echo "Failure Requests by Hour:" >> "$REPORT_FILE"
echo "$FAILURE_HOURS" | while read -r count hour; do
    echo "Hour $hour: $count failures" >> "$REPORT_FILE"
done
echo "" >> "$REPORT_FILE"

# 11. Request Trends
echo "11. Request Trends" >> "$REPORT_FILE"
echo "Analyzing request patterns:" >> "$REPORT_FILE"
PEAK_HOUR=$(echo "$HOURLY_REQUESTS" | sort -nr | head -1 | awk '{print $2}')
PEAK_COUNT=$(echo "$HOURLY_REQUESTS" | sort -nr | head -1 | awk '{print $1}')
LOW_HOUR=$(echo "$HOURLY_REQUESTS" | sort -n | head -1 | awk '{print $2}')
LOW_COUNT=$(echo "$HOURLY_REQUESTS" | sort -n | head -1 | awk '{print $1}')
echo "Peak request hour: $PEAK_HOUR with $PEAK_COUNT requests" >> "$REPORT_FILE"
echo "Lowest request hour: $LOW_HOUR with $LOW_COUNT requests" >> "$REPORT_FILE"
echo "Trend: Requests peak during hour $PEAK_HOUR, indicating high server load." >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"


# Display report
cat "$REPORT_FILE"
