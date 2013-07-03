class GitPush
  constructor: (@data) ->
    @created = @data.created_at
    console.log @data
    @repo_url = @data.repo.url
    @repo_name = @data.repo.name
    @commits = @parse_commits(@data.payload.commits)

  parse_commits: (commits) ->
    for commit in commits
      {
        "message": commit.message,
        "url": commit.url
      }

  to_html: () ->
    commits = for commit in @commits
      """
      <pre>#{commit.message}</pre>
      <a href = "#{fix_api_url commit.url}" class = "commit-link">view</a>
      """
    div = document.createElement("div");
    div.setAttribute("class", "github-event")
    div.innerHTML = """
      <a href = "#{fix_api_url @repo_url}"><h2>#{@repo_name}</h2></a>
      #{commits}
    """
    return div

fix_api_url = (url) ->
  url.replace "https://api.github.com/repos", "https://github.com"

parse_data = (data) ->
  push_events = data.filter (x) -> x.type == "PushEvent"
  for event_data in push_events
    new GitPush(event_data)

callback = (data) ->
  response = data["data"];
  meta = data["meta"];
  draw(parse_data(response))

draw = (events) ->
  container = document.getElementById("github-feed")
  for event in events
    container.appendChild(event.to_html())
  container.style.display = "block"

get_data = () ->
  container = document.getElementById("github-feed")
  username = container.getAttribute("github-username")
  script = document.createElement('script');
  script.src = "https://api.github.com/users/#{username}/events?callback=callback"
  console.log username
  document.getElementsByTagName('head')[0].appendChild(script)

initialize = () ->
  old_onload = window.onload
  window.onload = () ->
    get_data()
    style = document.createElement("link")
    style.setAttribute("rel", "stylesheet")
    style.setAttribute("type", "text/css")
    style.setAttribute("href", "github_events.css")
    document.getElementsByTagName('head')[0].appendChild(style)


initialize()