# prfls app

# What it does?

- Fetches profiles
- Presenting profiles 
- Checking profile details

# Technical solutions 
- MVVM architecture
- Profiles are fetched in pages of size 20
- Profiles are presented using UITableView 
- Diffable datasource for smooth showing of a freshly loaded page
- Unit test covering data fetching, passing and validity 
- No use of external libraries and frameworks since the app is small and everything can be handeled without hussle 
    - If needed I would use cocoapods with:
        - Alamofire for url requests
        - CocoaLumberjack for log levels
        - SDWebImage for async image loading