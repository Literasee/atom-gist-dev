module.exports = (repo_url) ->
  tmp = repo_url.split('/')
  repo_name = tmp[tmp.length-1]
  tmp = repo_name.split('.')
  repo_name = tmp[...-1].join('.')
