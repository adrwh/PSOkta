#### Get-Okta

`get-okta` 
- users
    - q
    - filter
        - "status","lastUpdated"
    - search
- groups
    - q, filter
- applications GET /api/v1/apps
    - q, filter
- factors GET /api/v1/users/${userId}/factors
- Reset Factor DELETE /api/v1/users/${userId}/factors/${factorId}



[-q or -search or -filter] [string]"query"

